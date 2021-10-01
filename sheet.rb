require 'nokogiri'

NS = {
    mods: 'http://www.loc.gov/mods/v3',
    mets: 'http://www.loc.gov/METS/',
}

# loop through institution mets XMLs
Dir["/Volumes/sceti-completed-4/DS-Legacy-Data/METS/digitalassets.lib.berkeley.edu/ds/#{ARGV[0]}/mets/*.xml"].each do |f|
  xml = File.open(f) { |x| Nokogiri::XML x }
  nodes = xml.xpath('//mets:dmdSec[./mets:mdWrap/mets:xmlData/mods:mods/mods:identifier/@type="filename"]', NS)
  nodes.each do |node|
    dmdSec = node.attr("ID").to_s
    mets_tif = node.xpath('//mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type="filename"]/text()')
    mets_tif.each do |m|
      puts [ARGV.first, f, dmdSec, m.to_s].inspect
    end
  end
end
