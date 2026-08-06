# frozen_string_literal: true
module DS
  module Manifest
    class EntryIdentity

      attr_reader :entry

      ##
      # @param entry [DS::Manifest::Entry] the entry
      def initialize entry
        @entry = entry
      end

      def to_h
        {
          institution_ds_qid: normal_institution_ds_qid,
          institutional_id: normal_institutional_id,
          call_number: normal_call_number,
          link_to_institutional_record: normal_link_to_institutional_record
        }
      end

      def hash
        to_h.hash
      end

      def eql?(other)
        self.class == other.class &&
          normal_institution_ds_qid == other.normal_institution_ds_qid &&
          normal_institutional_id == other.normal_institutional_id &&
          normal_call_number == other.normal_call_number &&
          normal_link_to_institutional_record == other.normal_link_to_institutional_record
      end
      alias == :eql?

      def to_s
        "EntryIdentity: #{to_h.to_s}"
      end

      protected

      ##
      # Normalized version of institution_ds_qid: the uppercase QID
      # @return [String]
      def normal_institution_ds_qid
        entry.institution_ds_qid.to_s.upcase
      end

      ##
      # Normalized version of the institutional_id: the institutional_id with
      # the record's institutional_id with all non-alphanumeric characters,
      # including whitespace removed, and converted to lowercase.
      # @return [String] the normalized institutional_id
      def normal_institutional_id
        return '' if entry.institutional_id.blank?

        entry.institutional_id.to_s.gsub(/[^[:alnum:]]/, '').downcase
      end

      ##
      # Normalized version of the call_number: the call_number with
      # the record's call_number with all non-alphanumeric characters,
      # including whitespace removed, and converted to lowercase.
      # @return [String] the normalized call_number
      def normal_call_number
        return '' if entry.call_number.blank?

        entry.call_number.to_s.gsub(/[^[:alnum:]]/, '').downcase
      end

      ##
      # The unaltered link_to_institutional_record. Links to insituional records
      # much match exactly.
      # @return [String] the unaltered link_to_institutional_record
      def normal_link_to_institutional_record
        entry.link_to_institutional_record
      end

    end
  end
end
