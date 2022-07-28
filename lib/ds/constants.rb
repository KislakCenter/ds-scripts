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
production_place_label
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
genre_label
subject_as_recorded
subject
subject_label
author_as_recorded
author_as_recorded_agr
author
author_wikidata
author_instance_of
author_label
artist_as_recorded
artist_as_recorded_agr
artist
artist_label
artist_wikidata
artist_instance_of
scribe_as_recorded
scribe_as_recorded_agr
scribe
scribe_label
scribe_wikidata
scribe_instance_of
language_as_recorded
language
language_label
former_owner_as_recorded
former_owner_as_recorded_agr
former_owner
former_owner_label
former_owner_wikidata
former_owner_instance_of
material_as_recorded
material
material_label
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
      1  => 'ucb',
      2  => 'harvard',
      3  => 'fordham',
      4  => 'freelib',
      5  => 'cuny',
      6  => 'rutgers',
      7  => 'ucd',
      8  => 'ucb',
      9  => 'csl',
      10 => 'ucr',
      11 => 'ucb',
      12 => 'csl',
      13 => 'sfu',
      14 => 'notredame',
      15 => 'conception',
      16 => 'columbia',
      17 => 'columbia',
      18 => 'columbia',
      19 => 'columbia',
      20 => 'columbia',
      21 => 'columbia',
      22 => 'columbia',
      23 => 'gts',
      24 => 'grolier',
      25 => 'nyu',
      26 => 'oberlin',
      27 => 'penn',
      28 => 'providence',
      29 => 'rome',
      30 => 'kansas',
      31 => 'jhopkins',
      32 => 'jhopkins',
      33 => 'jhopkins',
      34 => 'jhopkins',
      35 => 'walters',
      36 => 'pittsburgh',
      37 => 'txaustin',
      38 => 'uvm',
      39 => 'jtsa',
      40 => 'indiana',
      41 => 'nypl',
      42 => 'nypl',
      43 => 'huntington',
      44 => 'slu',
      45 => 'missouri',
      46 => 'nelsonatkins',
      47 => 'beinecke',
      48 => 'smith',
      50 => 'wellesley',
      52 => 'tufts'
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