module Recon
  module IIIFManifests
    module ClassMethods
      def find_iiif_manifest holding_institution, shelfmark
        key                 = iiif_manifest_key holding_institution, shelfmark
        iiif_manifests[key]
      end

      @@iiif_manifests = nil

      def iiif_manifests
        return @@iiif_manifests if @@iiif_manifests
        recon_repo = File.join DS.root, 'data', Settings.recon.git_local_name
        csv_file   = File.join recon_repo, Settings.recon.iiif_manifests

        @@iiif_manifests = CSV.readlines(csv_file, headers: true).inject({}) { |h, row|
          key = iiif_manifest_key row['holding_institution'], row['shelfmark']
          h.merge(key => row['iiif_manifest_url'])
        }
      end

      def iiif_manifest_key holder, shelfmark
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