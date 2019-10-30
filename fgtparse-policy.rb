#This script will pass the output of the 'show firewall policy' command on a Fortigate firewall
#Usage: ruby fgtparse-policy.rb <file.txt>

require 'csv'

#Select script output format - either 'csv' or 'stdout'
outputFormat = "csv"

#Only used if outputFormat is 'csv'
outputFile = "output.csv"

#Hash of config items scraped from configuration
#Format <config item> => <Human readable heading>
outputFields = {
  "pid" => "Policy ID",
  "name" => "Name",
  "status" => "Status",
  "srcintf" => "Source Interface",
  "dstintf" => "Destination Interface",
  "srcaddr" => "Source Address",
  "dstaddr" => "Destination Address",
  "service" => "Service",
  "action" => "Action",
  "schedule" => "Schedule",
  "nat" => "NAT",
  "poolname" => "NAT Pool"
}

def parseFile(inputFile)
  #Scrape through configuration file line by line
  #Create 'currentPolicy' hash for each policy and add to 'ruleset' array
  #Returns 'ruleset' array for output

  #Create empty array to hold policy hashes
  ruleset = []
  #Create empty hash to hold policy elements
  currentPolicy = {}

  File.open(inputFile).each do |line|
    case line.strip
      when /edit ([\d]*)/
        currentPolicy["pid"] = $1
      when /set ([\w-]*) (.*)/
        currentPolicy[$1] = $2
      when /next|identity-based-policy/
        completePolicy = currentPolicy.dup
        ruleset << completePolicy
        currentPolicy.clear
    end
  end
  return ruleset
end

def outputSTDOUT(ruleset, outputFields)
  #Output each policy in human readable format to STDOUT
  ruleset.each do |rule|
    outputFields.keys.each do |key|
      if rule.key?(key) then puts "#{outputFields[key]}: #{rule[key]}" end
    end
    puts "\n"
  end
end

def outputCSV(outputFile, ruleset, outputFields)
  #Output policies to a CSV file

  #Build CSV Headings
  headings = []
  outputFields.keys.each do |key|
    headings << outputFields[key]
  end

  CSV.open(outputFile, "w") do |csv|
    csv << headings
    ruleset.each do |rule|
      line = []
      outputFields.keys.each do |key|
        if rule.key?(key) then line << rule[key] else line << "" end
      end
      csv << line
    end
  end
end

#Main script execution
ruleset = parseFile(ARGV[0])

case outputFormat
  when "csv"
    outputCSV(outputFile, ruleset, outputFields)
  when "stdout"
    outputSTDOUT(ruleset, outputFields)
end
