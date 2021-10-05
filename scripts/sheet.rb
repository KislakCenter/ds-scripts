require 'nokogiri'
require 'pry'
require 'csv'

NS = {
  mods: 'http://www.loc.gov/mods/v3',
  mets: 'http://www.loc.gov/METS/'
}.freeze
institution = ARGV.first
mets_dir = "/Volumes/sceti-completed-4/DS-Legacy-Data/METS/digitalassets.lib.berkeley.edu/ds/#{institution}/mets/*.xml"

def matching_tif(path, regex, dummy)
  images        = Dir[path]
  mets_image_id = /#{regex}/.match(dummy)
  match         = images.grep(/#{mets_image_id}/).first
  match&.sub(%r{^/Volumes/sceti-completed-4/}, '')
end

# loop through institution mets XMLs
Dir[mets_dir].each do |f|
  xml   = File.open(f) { |x| Nokogiri::XML x }
  nodes = xml.xpath('//mets:dmdSec[./mets:mdWrap/mets:xmlData/mods:mods/mods:identifier/@type="filename"]', NS)
  nodes.each do |node|
    dmdSec   = node.attr('ID').to_s
    mets_tif = node.xpath('mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type="filename"]/text()')
    # puts mets_tif

    mets_tif.each do |m|
      case institution
      when 'csl'
      when 'cuny'
        # returns none
        # path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/cuny/ccny/images/*.tif'
      when 'conception'
        # returns none
        # path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/conception/conception_abbey/images/*.tif'
      when 'gts'
        path  = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/gts/general_theological/images/*.tif'
        match = matching_tif(path, '\d{7}', m)
      when 'grolier'
        # path     = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/grolier/grolier/images/GC_10_01_09/Processed/*.tif'
      when 'indiana'
        # indiana must be searched recursively
        # only 2 filenames in XML, but many more images in TIF folder
        path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/indiana/indiana/images/**/*.tif'
      when 'nyu'
        path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/nyu/nyu/images/*.tif'
        match = matching_tif(path, '\d{7}', m)
      when 'providence'
      when 'rutgers'
      when 'nelsonatkins'
      when 'ucb'
      when 'kansas'
      when 'wellesley'
      end
      match = 'No match.' if match.nil?
      row = [institution, f.sub(%r{^/Volumes/sceti-completed-4/}, ''),
            dmdSec,
            m.to_s,
            match]
      puts row.inspect
      # CSV.open("ds2_dependent_images.csv", "a") do |csv|
      #   csv << row
      # end
    end
  end
end
