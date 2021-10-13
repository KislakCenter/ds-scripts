require 'nokogiri'
require 'pry'
require 'csv'

require_relative '../lib/ds'

NS = {
  mods: 'http://www.loc.gov/mods/v3',
  mets: 'http://www.loc.gov/METS/'
}.freeze
institution = ARGV.first
# /Volumes/sceti-completed-4/DS-Legacy-Data/METS
mets_dir = "/Volumes/sceti-completed-4/DS-Legacy-Data/METS/digitalassets.lib.berkeley.edu/ds/#{institution}/mets/*.xml"
# puts mets_dir

def matching_tif(path, regex, dummy)
  images        = Dir[path]
  mets_image_id = /#{regex}/.match(dummy)
  match         = images.grep(/#{mets_image_id}/).first
  match&.sub(%r{^/Volumes/sceti-completed-4/}, '')
end

def atkins_rename m
  if m.include? 'LEV'
    # GouldCollection030LEVerecto.tif
    # mets_image_id = m.sub(/GouldCollection(\d+)([a-z])(recto|verso)(detail)(\d)(.*)$/,
    #                       'Gould_Collection_\1_\2_\3\4')
    if m.match /([a-z])(recto|verso)(detail)/
      # GouldCollection030LEVerectodetail1.tif
      m.sub(/GouldCollection(\d+)(LEV)([a-z])(recto|verso)(detail)(\d)(.*)$/,
            'Gould_Collection_\1_\2_\3_\4_\5_\6\7')
    else
      # GouldCollection030LEVeverso.tif
      m.sub(/GouldCollection(\d+)(LEV)([a-z])(recto|verso)(.*)$/,
            'Gould_Collection_\1_\2_\3_\4\5')
    end
  elsif m.include? 'folio'
    # GouldCollection039foliorecto.tif
    m.sub(/GouldCollection(\d+)(folio)(recto|verso)(.*)$/,
          'Gould_Collection_\1_\2_\3\4')
  elsif m.include? 'versodetail'
    # GouldCollection015versodetail.tif
    m.sub(/GouldCollection(\d+)(recto|verso)(detail)(.*)$/,
          'Gould_Collection_\1_\2_\3\4')
    # HOW DO WE GET THIS CONDITION TO WORK??????
  elsif %w[a_recto b_recto c_recto a_verso b_verso c_verso].any? { |s| m.include? s }
    # GouldCollection002brecto.tif
    m.sub(/GouldCollection(\d+)([a-z])(recto|verso)(.*)$/,
          'Gould_Collection_\1_\2_\3\4')
  else
    # GouldCollection014recto.tif
    m.sub(/GouldCollection(\d+)(recto|verso)(.*)$/,
          'Gould_Collection_\1_\2\3')
  end
end

raise 'METS directory not found.' unless Dir[mets_dir].any?

# loop through institution mets XMLs
Dir[mets_dir].each do |f|
  xml   = File.open(f) { |x| Nokogiri::XML x }
  pages = DS::DS10.find_pages xml
  unless pages.any?
    row = [institution, f.sub(%r{^/Volumes/sceti-completed-4/}, '')] unless pages.any?
    # CSV.open("ds2_dependent_images_v2.csv", "a+") do |csv|
    #   csv << []
    #   csv << row
    # end
  end
  pages.each do |page|
    dmdSec   = page.attr('ID').to_s
    mets_tif = DS::DS10.extract_filenames page

    mets_tif.each do |m|
      case institution
      when 'csl'
        # NO TIFS
      when 'cuny'
        path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/cuny/ccny/images/*.tif'
        match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
      when 'conception'
        # extra TIF files at path that looks like `CA_details3002`
        path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/conception/conception_abbey/images/*.tif'
        match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
      when 'gts'
        path  = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/gts/general_theological/images/*.tif'
        match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
      when 'grolier'
        path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/grolier/grolier/images/GC_10_01_09/Processed/*.tif'
        match = matching_tif(path, '\d{7}', m) unless m == 'NO_FILE'
      when 'indiana'
        path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/indiana/indiana/images/**/*.tif'
        images = Dir[path]
        mets_image_id = m.sub(/^dummy_InU-Li_/, '')
        match = images.grep(/#{mets_image_id.downcase}/).first
        match&.sub(%r{^/Volumes/sceti-completed-4/}, '')
        # must differentiate between all different kinds of filenames
      when 'nyu'
        path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/nyu/nyu/images/*.tif'
        match = matching_tif(path, '\d{7}', m)
      when 'providence'
        # no filenames in mets
        # path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/providence/providence/images/*.tif'
      when 'rutgers'
        # no filenames in mets
      when 'nelsonatkins'
        # 141 filenames in mets
        path = '/Volumes/sceti-completed-4/DS-Legacy-Data/TIF/Box/nelsonatkins/images/*.tif'
        images = Dir[path]
        # if match isn't nil, return match
        # regex sub underscores, capture groups, back references
        puts atkins_rename(m)
      when 'ucb'
        # only 3 tiffs, can manually match
      when 'kansas'
      when 'wellesley'
        # 423 matches
      end
      # match = match.first unless match.count >= 2
      match = 'NO_MATCH' if match.nil?
      row = [institution, f.sub(%r{^/Volumes/sceti-completed-4/}, ''),
            dmdSec,
            m.to_s,
            match]
      # puts row.inspect
      # CSV.open("ds2_dependent_images_v2.csv", "a+") do |csv|
      #   csv << []
      #   csv << row
      # end
    end
  end
end
