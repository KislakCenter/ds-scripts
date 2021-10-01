require 'nokogiri'

NS = {
    mods: 'http://www.loc.gov/mods/v3',
    mets: 'http://www.loc.gov/METS/',
}

institution = ARGV.first

# loop through institution mets XMLs
Dir["/Volumes/sceti-completed-4/DS-Legacy-Data/METS/digitalassets.lib.berkeley.edu/ds/#{institution}/mets/*.xml"].each do |f|
  xml = File.open(f) { |x| Nokogiri::XML x }
  nodes = xml.xpath('//mets:dmdSec[./mets:mdWrap/mets:xmlData/mods:mods/mods:identifier/@type="filename"]', NS)
  nodes.each do |node|
    dmdSec = node.attr("ID").to_s
    mets_tif = node.xpath('mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type="filename"]/text()')

    case institution
    when 'csl'
    when 'cuny'
    when 'conception'
    when 'gts'
    when 'grolier'
    when 'indiana'
    when 'nyu'
    when 'providence'
    when 'rutgers'
    when 'nelsonatkins'
    when 'ucb'
    when 'kansas'
    when 'wellesley'
    end

    mets_tif.each do |m|
      puts [institution, f.sub(%r{^/Volumes/sceti-completed-4/}, ''), dmdSec, m.to_s].inspect
    end
  end
end
