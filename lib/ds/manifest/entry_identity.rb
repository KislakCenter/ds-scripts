# frozen_string_literal: true
module DS
  module Manifest
    class EntryIdentity < Entry
      ##
      # An Entry Identity is a subclass of Entry which helps determines its uniqueness.
      #
      # Entry Identity is determined by the institution_ds_qid, institutional_id, call_number
      # and link_to_institutional_record. EntryIdentity is used to compare an entry
      # with other entry identities to determine its uniqueness.
      #
      def to_h
        {
          institution_ds_qid: institution_ds_qid.upcase,
          institutional_id: institutional_id.to_s.gsub(/[^[:alnum:]]/, '').downcase,
          call_number: call_number.to_s.gsub(/[^[:alnum:]]/, '').downcase,
          link_to_institutional_record: link_to_institutional_record
        }
      end

      def hash
        to_h.hash
      end

      def eql?(other)
        other.class == self.class && to_h == other.to_h
      end
    end
  end
end
