#!/usr/bin/env ruby

require 'open-uri'
require 'csv'

require 'nokogiri'

def get_api_works_xml(orcid)
  contents = nil
  open("http://pub.orcid.org/v1.2/#{orcid}/orcid-works",
       'Accept' => 'application/orcid+xml') do |f|
    contents = f.read
  end
  contents
end


def extract(orcid, xmldata)
  doc = Nokogiri::XML(xmldata)
  ns = 'http://www.orcid.org/ns/orcid'
  doc.xpath('//ns:orcid-works/ns:orcid-work', 'ns' => ns).map do |work|
    {
      'orcid' => orcid,
      'work-type' => work.xpath('./ns:work-type', 'ns' => ns).text,
      'title' => work.xpath('./ns:work-title/ns:title', 'ns' => ns).text,
      'contributors' => work.xpath('./ns:work-contributors/ns:contributor/ns:credit-name', 'ns' => ns).map(&:text).join('; '),
      'url' => work.xpath('./ns:url', 'ns' => ns).text,
    }
  end
end

def write_headers(csvfile, record)
  csvfile << record.keys
end

def to_csv(csvfile, records)
  # write records
  records.each do |record|
    csvfile << record.keys.map do |key|
      record[key]
    end
  end
end

def fetch(orcid)
  path = "data/#{orcid}.xml"
  if File.exist?("data/#{orcid}.xml")
    contents = File.read(path)
  else
    contents = get_api_works_xml(orcid)
    File.open(path, 'w') { |f| f.write(contents) }
  end
  extract(orcid, contents)
end

def main
  csvfile = CSV.open('publications.csv', 'wb')
  headers_written = false

  open('orcids.txt').select { |line| !line.strip.start_with?('#') }.each do |line|
    orcid = line.strip
    pubs = fetch(orcid)
    if !headers_written && pubs.size > 0
      write_headers(csvfile, pubs[0])
      headers_written = true
    end
    to_csv(csvfile, pubs)
  end

  csvfile.close
end

main
