module Recon
  class Subjects
    def self.from_marc files, tags: []
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          data += DS::MarcXML.collect_datafield_sets record, tags: tags, codes: ('a'..'z').to_a, sub_sep: '--'
        end
      end
      data.sort.uniq
    end

    def self.from_mets files
      raise NotImplementedError
    end

    def self.from_tei files
      raise NotImplementedError
    end
  end
end