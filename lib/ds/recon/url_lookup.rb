module Recon
  class URLLookup

    attr_reader :lookup_set
    attr_reader :url_hash

    ##
    # The name of the lookup set in `config/recon.yml`. For example, for
    #
    #     ---
    #     recon:
    #       # ...
    #       iiif_manifests: iiif/legacy-iiif-manifests.csv
    #
    #  the +lookup_set+ is 'iiif_manifests'.
    #
    # @param [String] lookup_set the name of the recon setting
    def initialize lookup_set
      @lookup_set = lookup_set
      @url_hash = {}
    end

    def find_url holding_institution, shelfmark
      key = url_key holding_institution, shelfmark
      urls[key]
    end

    @url_hash = nil

    def urls
      return url_hash unless url_hash.empty?
      recon_repo = File.join DS.root, 'data', Settings.recon.git_local_name
      csv_file   = File.join recon_repo, Settings.recon[lookup_set]

      CSV.readlines(csv_file, headers: true).each { |row|
        key = url_key row['holding_institution'], row['shelfmark']
        url_hash[key] = row['url']
      }
      url_hash
    end

    def url_key holder, shelfmark
      qid = DS::Institutions.find_qid holder
      raise DSError, "No QID found for #{holder}" if qid.blank?
      normalize_key qid, shelfmark
    end

    def normalize_key *strings
      strings.join.downcase.gsub(%r{\s+}, '')
    end
  end
end