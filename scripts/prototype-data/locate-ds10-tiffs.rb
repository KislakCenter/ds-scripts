require 'nokogiri'
require 'pry'
require 'csv'

require_relative '../lib/ds'

NS = {
  mods: 'http://www.loc.gov/mods/v3',
  mets: 'http://www.loc.gov/METS/'
}.freeze

# the isntitutions that are dependent on DS for their data
DEPENDENT_ON_DS = %w[
  conception
  csl
  cuny
  grolier
  gts
  indiana
  kansas
  nelsonatkins
  nyu
  providence
  rutgers
  ucb
  wellesley
].sort.freeze

# find the matching tif for a given dummy filename
def matching_tif(path, regex, dummy)
  images        = Dir[path]
  mets_image_id = /#{regex}/.match(dummy)
  match         = images.grep(/#{mets_image_id}/).first
  match&.sub(%r{^/Volumes/sceti-completed-4/DS-Legacy-Data/}, '')
end

# adjust nelsonatkins filenames to match TIF filenames
def atkins_rename m
  m = File.basename m, '.tif' if m.include? '_'
  m = m.gsub '__', '_' if m.include? '__'
  if m.include? 'LEV'
    # GouldCollection030LEVerecto.tif
    if m.match /([a-z])(recto|verso)(detail)/
      # GouldCollection030LEVerectodetail1.tif
      m.sub(/GouldCollection(\d+)(LEV)([a-z])(recto|verso)(detail)(\d)(.*)$/,
            'Gould_Collection_\1_\2_\3_\4_\5')
    else
      # GouldCollection030LEVeverso.tif
      m.sub(/GouldCollection(\d+)(LEV)([a-z])(recto|verso)(.*)$/,
            'Gould_Collection_\1_\2_\3_\4')
    end
  elsif m.include? 'folio'
    # GouldCollection039foliorecto.tif
    m.sub(/GouldCollection(\d+)(folio)(recto|verso)(.*)$/,
          'Gould_Collection_\1_\2_\3')
  elsif m.include? 'versodetail'
    # GouldCollection015versodetail.tif
    m.sub(/GouldCollection(\d+)(recto|verso)(detail)(.*)$/,
          'Gould_Collection_\1_\2_\3')
  else
    # GouldCollection014recto.tif
    m.sub(/GouldCollection(\d+)(recto|verso)(.*)$/,
          'Gould_Collection_\1_\2')
  end
end

# loop through each institution
DEPENDENT_ON_DS.each do |institution|
  puts "working on #{institution}..."
  mets_dir = "/Users/emeryr/NoBackup/ds/digitalassets.lib.berkeley.edu/ds/#{institution}/mets/*.xml"
  raise 'METS directory not found.' unless Dir[mets_dir].any?

  # loop through an institution's METS XMLs
  Dir[mets_dir].each do |f|
    xml   = File.open(f) { |x| Nokogiri::XML x }
    pages = DS::DsMetsXml.find_pages xml
    # insert row into CSV even if no pages are found
    unless pages.any?
      row = [institution, f.sub(%r{^/Volumes/sceti-completed-4/}, '')] unless pages.any?
      CSV.open('ds2_tifs.csv', 'a+') do |csv|
        csv << []
        csv << row
      end
    end
    # loop through each page and get TIF filenames
    pages.each do |page|
      dmdSec   = page.attr('ID').to_s
      mets_tif = DS::DsMetsXml.extract_filenames page

      # loop through each TIF filename and find a matching TIF image
      mets_tif.each do |m|
        case institution
        when 'csl'
          # NO TIFS
        when 'cuny'
          path  = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/cuny/ccny/images/*.tif'
          match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
        when 'conception'
          # extra TIF files at path that looks like `CA_details3002`
          path  = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/conception/conception_abbey/images/*.tif'
          match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
        when 'gts'
          path  = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/gts/general_theological/images/*.tif'
          match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
        when 'grolier'
          path  = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/grolier/grolier/images/GC_10_01_09/Processed/*.tif'
          match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
        when 'indiana'
          path          = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/indiana/indiana/images/**/*.tif'
          images        = Dir[path]
          mets_image_id = m.sub(/^dummy_InU-Li_/, '')
          match         = images.grep(/#{mets_image_id.downcase}/).first
          match = match.sub(%r{^/Volumes/sceti-completed-4/DS-Legacy-Data/}, '') unless match.nil?
        when 'nyu'
          path  = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/nyu/nyu/images/*.tif'
          match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
        when 'providence'
          path  = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/providence/providence/images/*.tif'
          match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
        when 'rutgers'
          # no filenames in mets
          path  = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/rutgers/rutgers/images/*.tif'
          match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
        when 'nelsonatkins'
          # 141 filenames in mets
          path          = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/nelsonatkins/images/*.tif'
          images        = Dir[path]
          mets_image_id = atkins_rename m
          # puts mets_image_id
          match = images.grep(/#{mets_image_id}/).first
          match = match.sub(%r{^/Volumes/sceti-completed-4/DS-Legacy-Data/}, '') unless match.nil?
        when 'ucb'
          # only 3 tiffs, can manually match (if they actually match at all)
          match = 'NO_MATCH'
        when 'kansas'
          path  = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/kansas/kansas/images/Master/*.tif'
          match = matching_tif(path, '\d{4}', m) unless m == 'NO_FILE'
        when 'wellesley'
          # 423 tifs
          match = 'NO_MATCH'
        end
        # stick string into the CSV insead of empty/nil values
        match = 'NO_MATCH' if m == 'NO_FILE'
        match = 'NO_MATCH' if match.nil?
        # put together CSV row
        puts match
        row   = [institution, f.sub(%r{^/Volumes/sceti-completed-4/DS-Legacy-Data/}, ''),
                 dmdSec,
                 m.to_s,
                 match]
        # write to CSV
        CSV.open('ds2_tifs.csv', 'a+') do |csv|
          csv << []
          csv << row
        end
      end
    end
  end
  puts "#{institution} completed"
end
