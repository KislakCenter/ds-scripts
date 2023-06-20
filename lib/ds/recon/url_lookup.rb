module Recon
  module URLLookup
    module ClassMethods
      def find_url holding_institution, shelfmark
        key = url_key holding_institution, shelfmark
        urls[key]
      end

      @@url_hash = nil

      def urls
        return @@url_hash if @@url_hash
        recon_repo = File.join DS.root, 'data', Settings.recon.git_local_name
        csv_file   = File.join recon_repo, Settings.recon.iiif_manifests

        @@url_hash = CSV.readlines(csv_file, headers: true).inject({}) { |h, row|
          key = url_key row['holding_institution'], row['shelfmark']
          h.merge(key => row['url'])
        }
      end

      def url_key holder, shelfmark
        qid = DS::Institutions.find_qid holder
        raise DSError, "No QID found for #{holder}" if qid.to_s.empty?
        normalize_key qid, shelfmark
      end

      def normalize_key *strings
        strings.join.downcase.gsub(%r{\s+}, '')
      end
    end
    self.extend ClassMethods
  end
end