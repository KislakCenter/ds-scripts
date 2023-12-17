# frozen_string_literal: true

module DS
  module Extractor
    class ExtractorBase

      ############################################################
      # HOLDING INFORMATION
      ############################################################

      def extract_holding_institution record
        raise NotImplementedError
      end

      def extract_holding_institution_id_nummber record
        raise NotImplementedError
      end

      def extract_shelfmark record
        raise NotImplementedError
      end

      def extract_link_to_record record
        raise NotImplementedError
      end

      ############################################################
      # TITLES
      ############################################################

      def extract_titles record
        raise NotImplementedError
      end

      def extract_title_as_recorded record
        raise NotImplementedError
      end

      def extract_title_as_recorded_agr record
        raise NotImplementedError
      end

      def extract_recon_titles record
        raise NotImplementedError
      end

      ############################################################
      # NAMES
      ############################################################

      def extract_authors record
        raise NotImplementedError
      end

      def extract_authors_as_recorded record
        raise NotImplementedError
      end

      def extract_authors_agr record
        raise NotImplementedError
      end

      def extract_resps record, *resp_names
        raise NotImplementedError
      end

      def extract_recon_names record
        raise NotImplementedError
      end

      def extract_artists_as_recorded record
        raise NotImplementedError
      end

      def extract_artists_agr record
        raise NotImplementedError
      end

      def extract_scribes_as_recorded record
        raise NotImplementedError
      end

      def extract_scribes_agr record
        raise NotImplementedError
      end

      def extract_former_owners_as_recorded record
        raise NotImplementedError
      end

      def extract_former_owners_agr record
        raise NotImplementedError
      end

      ############################################################
      # MATERIALS
      ############################################################

      def extract_material_as_recorded record
        raise NotImplementedError
      end

      ############################################################
      # LANGUAGES
      ############################################################

      def extract_language_as_recorded record, separator: '|'
        raise NotImplementedError
      end

      def extract_language_codes record, separator: '|'
        raise NotImplementedError
      end

      ############################################################
      # TERMS: GENRES AND SUBJECTS
      ############################################################

      def extract_recon_genres record
        raise NotImplementedError
      end

      def extract_recon_subjects record
        raise NotImplementedError
      end

      def extract_genre_as_recorded record
        raise NotImplementedError
      end

      def extract_subject_as_recorded record
        raise NotImplementedError
      end

      ############################################################
      # ORIGIN: PLACES AND DATES
      ############################################################

      def extract_production_place record
        raise NotImplementedError
      end

      def extract_recon_places record
        raise NotImplementedError
      end

      def extract_production_date record, range_sep: '-'
        raise NotImplementedError
      end

      ############################################################
      # PHYSICAL DESCRIPTION
      ############################################################

      def extract_physical_description record
        raise NotImplementedError
      end

      ############################################################
      # NOTES
      ############################################################

      def extract_note record
        raise NotImplementedError
      end

      def build_notes record, xpath, prefix: nil
        raise NotImplementedError
      end

      ############################################################
      # ACKNOWLEDGMENTS
      ############################################################

      def extract_funder record
        raise NotImplementedError
      end

      def extract_acknowledgments record
        raise NotImplementedError
      end

      ############################################################
      # UTILITY METHODS
      ############################################################

      def extract_normalized_strings record, xpath
        raise NotImplementedError
      end

      def source_modified record
        raise NotImplementedError
      end

    end
  end
end