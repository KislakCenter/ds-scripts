require 'nokogiri'

module Recon
  class Materials
    def self.add_recon_values rows
      rows.each do |row|
        material_as_recorded = row.first
        material_uris = Recon.look_up 'materials', value: material_as_recorded, column: 'structured_value'
        row << material_uris.to_s.gsub('|', ';')
      end
    end

    def self.lookup materials
      materials.map { |material|
        material_uris = Recon.look_up 'materials', value: material, column: 'structured_value'
        material_uris.to_s.gsub '|', ';'
      }.join '|'
    end

    def self.from_marc files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          data << [DS::MarcXML.collect_datafields(record, tags: 300, codes: 'b')]
        end
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_mets files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        data << [DS::DS10.extract_support(xml)]
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_tei files
      data = []
      xpath = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p'
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        data << [xml.xpath(xpath).text]
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

  end
end