require 'nokogiri'

module Recon
  class Names
    def self.add_recon_values rows
      rows.each do |row|
        name = row.first
        row << Recon.look_up('names', key: name, column: 'name_wikidata')
        row << Recon.look_up('names', key: name, column: 'name_instance_of')
      end
    end

    def self.lookup names, column:
      # binding.pry unless names.grep(/Sacro Bosco, Joannes de, active 1230./).empty?
      names.map do|name|
        # binding.pry
        Recon.look_up 'names', key: name, column: column
      end
    end

    def self.from_marc files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          data += DS::MarcXML.extract_recon_names record, tags: [100, 110, 111]
          data += DS::MarcXML.extract_recon_names record, tags: [700, 710, 790, 791], relators: ['artist', 'illuminator', 'scribe', 'former owner']
        end
      end
      add_recon_values data
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_mets files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }

        data += DS::DS10.extract_recon_names xml
      end
      add_recon_values data
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_tei files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        nodes = xml.xpath('//msContents/msItem')
        data += DS::OPennTEI.extract_recon_names xml
      end
      add_recon_values data
      data.sort { |a, b| a.first <=> b.first }.uniq
    end
  end
end