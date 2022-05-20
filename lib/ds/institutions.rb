module DS
  ##
  # Class for access configure institutions. Values from
  # `config/institutions.yml`
  #
  # File contents look like:
  #
  #     ---
  #     institutions:
  #       Q814779:
  #         - Beinecke Rare Book & Manuscript Library
  #         - beinecke
  #       Q995265:
  #         - Bryn Mawr College
  #         - brynmawr
  #
  # +DS.configure!+ must be invoked before this class is accessed.
  module Institutions
    @@names_to_qids = nil

    ##
    # Return the contents of `config/institutions.yml' as hash with the
    # institution names as keys and the Wikidata QIDs as values.
    #
    # @return [Hash]
    def self.names_to_qids
      @@names_to_qids ||= Settings.institutions.inject({}) do |h, qid_names|
        qid = qid_names.first.to_s
        qid_names.last.inject(h) { |j, name| j.merge(name => qid) }
      end
    end

    ##
    # Return the QID for the give institution name/alias.
    #
    # @param [String] inst_alias a name of the institution
    # @return [String] the institution Wikidata QID
    def self.find_qid inst_alias
      # try without changes; and then normalize
      names_to_qids[inst_alias] or
        names_to_qids[inst_alias.to_s.strip] or
        names_to_qids[inst_alias.to_s.strip.downcase]
    end

    ##
    # Return the preferred name of the institution for the given alias.
    #
    # @param [String] inst_alias a name of the institution
    # @return [String] the first list name of the institution
    def self.preferred_name inst_alias
      qid = find_qid inst_alias
      Settings.institutions[qid.to_sym].first
    end
  end
end