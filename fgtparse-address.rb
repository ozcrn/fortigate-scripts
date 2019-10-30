#This script will pass the output of the 'show firewall address' command on a Fortigate firewall
#Usage: ruby fgtparse-address.rb <file.txt>

require 'csv'

#Select script output format - either 'csv' or 'stdout'
outputFormat = "csv"

#Only used if outputFormat is 'csv'
outputFile = "output.csv"

#Hash of config items scraped from configuration
#Format <config item> => <Human readable heading>
outputFields = {
  "name" => "Name",
  "type" => "Object Type",
  "start-ip" => "Start IP",
  "end-ip" => "End IP",
  "subnet" => "Subnet"
}

def parseFile(inputFile)
  #Scrape through configuration file line by line
  #Create 'addressObject' hash for each address and add to 'addressList' array
  #Returns 'addressList' array for output

  #Create empty array to hold address hashes
  addressList = []
  #Create empty hash to hold address elements
  addressObject = {}

  File.open(inputFile).each do |line|
    case line.strip
      when /edit (.*)/
        addressObject["name"] = $1
      when /set ([\w-]*) (.*)/
        addressObject[$1] = $2
      when /next|identity-based-policy/
        completeObject = addressObject.dup
        addressList << completeObject
        addressObject.clear
    end
  end
  return addressList
end

def outputSTDOUT(addressList, outputFields)
  #Output each address in human readable format to STDOUT
  addressList.each do |address|
    outputFields.keys.each do |key|
      if address.key?(key) then puts "#{outputFields[key]}: #{address[key]}" end
    end
    puts "\n"
  end
end

def outputCSV(outputFile, addressList, outputFields)
  #Output addresses to a CSV file

  #Build CSV Headings
  headings = []
  outputFields.keys.each do |key|
    headings << outputFields[key]
  end

  CSV.open(outputFile, "w") do |csv|
    csv << headings
    addressList.each do |address|
      line = []
      outputFields.keys.each do |key|
        if address.key?(key) then line << address[key] else line << "" end
      end
      csv << line
    end
  end
end

#Main script execution
addressList = parseFile(ARGV[0])

case outputFormat
  when "csv"
    outputCSV(outputFile, addressList, outputFields)
  when "stdout"
    outputSTDOUT(addressList, outputFields)
end