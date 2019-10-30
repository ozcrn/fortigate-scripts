#This script will pass the output of the 'show firewall service custom' command on a Fortigate firewall
#Usage: ruby fgtparse-service.rb <file.txt>

require 'csv'

#Select script output format - either 'csv' or 'stdout'
outputFormat = "csv"

#Only used if outputFormat is 'csv'
outputFile = "output.csv"

#Hash of config items scraped from configuration
#Format <config item> => <Human readable heading>
outputFields = {
  "name" => "Name",
  "protocol" => "Protocol",
  "protocol-number" => "Protocol Number",
  "tcp-portrange" => "TCP Ports",
  "udp-portrange" => "UDP Ports"
}

def parseFile(inputFile)
  #Scrape through configuration file line by line
  #Create 'serviceObject' hash for each service and add to 'serviceList' array
  #Returns 'serviceList' array for output

  #Create empty array to hold service hashes
  serviceList = []
  #Create empty hash to hold service elements
  serviceObject = {}

  File.open(inputFile).each do |line|
    case line.strip
      when /edit (.*)/
        serviceObject["name"] = $1
      when /set ([\w-]*) (.*)/
        serviceObject[$1] = $2
      when /next|identity-based-policy/
        completeObject = serviceObject.dup
        serviceList << completeObject
        serviceObject.clear
    end
  end
  return serviceList
end

def outputSTDOUT(serviceList, outputFields)
  #Output each service in human readable format to STDOUT
  serviceList.each do |service|
    outputFields.keys.each do |key|
      if service.key?(key) then puts "#{outputFields[key]}: #{service[key]}" end
    end
    puts "\n"
  end
end

def outputCSV(outputFile, serviceList, outputFields)
  #Output services to a CSV file

  #Build CSV Headings
  headings = []
  outputFields.keys.each do |key|
    headings << outputFields[key]
  end

  CSV.open(outputFile, "w") do |csv|
    csv << headings
    serviceList.each do |service|
      line = []
      outputFields.keys.each do |key|
        if service.key?(key) then line << service[key] else line << "" end
      end
      csv << line
    end
  end
end

#Main script execution
serviceList = parseFile(ARGV[0])

case outputFormat
  when "csv"
    outputCSV(outputFile, serviceList, outputFields)
  when "stdout"
    outputSTDOUT(serviceList, outputFields)
end