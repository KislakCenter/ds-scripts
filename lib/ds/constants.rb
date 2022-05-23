module DS
  module Constants
    HEADINGS = %i{
ds_id
date_added
date_last_updated
source_type
holding_institution
holding_institution_as_recorded
holding_institution_id_number
link_to_holding_institution_record
iiif_manifest
production_place_as_recorded
production_place
production_date_as_recorded
production_date
century
century_aat
dated
uniform_title
uniform_title_as_recorded
uniform_title_agr
title_as_recorded_245
title_as_recorded_245_agr
genre_as_recorded
genre_vocabulary
genre
named_subject_as_recorded
named_subject
subject_as_recorded
subject
author_as_recorded
author_as_recorded_agr
author
author_wikidata
author_instance_of
artist_as_recorded
artist_as_recorded_agr
artist
artist_wikidata
artist_instance_of
scribe_as_recorded
scribe_as_recorded_agr
scribe
scribe_wikidata
scribe_instance_of
language_as_recorded
language
former_owner_as_recorded
former_owner_as_recorded_agr
former_owner
former_owner_wikidata
former_owner_instance_of
material
material_placeholder
physical_description
acknowledgements
data_processed_at
data_source_modified
source_file
}

    # Institutions dependent on DS and their DS IDs
    # Some institutions have more than one collection
    #
    # conception    15
    # csl           12, 9
    # cuny           5
    # grolier       24
    # gts           23
    # indiana       40
    # kansas        30
    # nelsonatkins  46
    # nyu           25
    # providence    28
    # rutgers        6
    # ucb            1, 8, 11
    # wellesley     50

    INSTITUTION_DS_IDS = {
      15 => 'conception',
      12 => 'csl',
      9  => 'csl',
      5  => 'cuny',
      24 => 'grolier',
      23 => 'gts',
      40 => 'indiana',
      30 => 'kansas',
      46 => 'nelsonatkins',
      25 => 'nyu',
      28 => 'providence',
      6  => 'rutgers',
      1  => 'ucb',
      8  => 'ucb',
      11 => 'ucb',
      50 => 'wellesley',
    }.freeze

    TRAILING_PUNCTUATION_RE = %r{[,.:!?;[:space:]]+$}

    INSTITUTIONS = INSTITUTION_DS_IDS.values.uniq.freeze

    MARC_XML = :marc
    METS_XML = :mets
    TEI_XML  = :tei
    DS_CSV   = :csv
    SOURCE_TYPES = [ MARC_XML, METS_XML, TEI_XML, DS_CSV ].freeze
  end
end