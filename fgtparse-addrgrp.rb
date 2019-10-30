#This script will pass the output of the 'show firewall addrgrp' command on a Fortigate firewall
#Usage: ruby fgtparse-addrgrp.rb <file.txt>

require 'csv'

#Select script output format - either 'csv' or 'stdout'
outputFormat = "csv"

#Only used if outputFormat is 'csv'
outputFile = "output.csv"

#Hash of config items scraped from configuration
#Format <config item> => <Human readable heading>
outputFields = {
  "name" => "Name",
  "member" => "Members"
}

def parseFile(inputFile)
  #Scrape through configuration file line by line
  #Create 'groupObject' hash for each group and add to 'groupList' array
  #Returns 'groupList' array for output

  #Create empty array to hold group hashes
  groupList = []
  #Create empty hash to hold group elements
  groupObject = {}

  File.open(inputFile).each do |line|
    case line.strip
      when /edit (.*)/
        groupObject["name"] = $1
      when /set ([\w-]*) (.*)/
        groupObject[$1] = $2
      when /next|identity-based-policy/
        completeObject = groupObject.dup
        groupList << completeObject
        groupObject.clear
    end
  end
  return groupList
end

def outputSTDOUT(groupList, outputFields)
  #Output each group in human readable format to STDOUT
  groupList.each do |group|
    outputFields.keys.each do |key|
      if group.key?(key) then puts "#{outputFields[key]}: #{group[key]}" end
    end
    puts "\n"
  end
end

def outputCSV(outputFile, groupList, outputFields)
  #Output groups to a CSV file

  #Build CSV Headings
  headings = []
  outputFields.keys.each do |key|
    headings << outputFields[key]
  end

  CSV.open(outputFile, "w") do |csv|
    csv << headings
    groupList.each do |group|
      line = []
      outputFields.keys.each do |key|
        if group.key?(key) then line << group[key] else line << "" end
      end
      csv << line
    end
  end
end

#Main script execution
groupList = parseFile(ARGV[0])

case outputFormat
  when "csv"
    outputCSV(outputFile, groupList, outputFields)
  when "stdout"
    outputSTDOUT(groupList, outputFields)
end