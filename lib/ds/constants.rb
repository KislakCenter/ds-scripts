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
genre_as_recorded_lcsh
genre_as_recorded_aat
genre_as_recorded_rbprov
genre_as_recorded_lcgft
genre
named_subject_as_recorded
subject_as_recorded
subject
author_as_recorded
author_as_recorded_agr
author
author_instance_of
artist_as_recorded
artist_as_recorded_agr
artist
artist_instance_of
scribe_as_recorded
scribe_as_recorded_agr
scribe
scribe_instance_of
language_as_recorded
language
former_owner_as_recorded
former_owner_as_recorded_agr
former_owner
former_owner_instance_of
material
material_placeholder
physical_description
acknowledgements
data_processed_at
data_source_modified
source_file
}

    # TODO: Switch from QID URLs to standalone IDs
    # TODO: Look at TOML for institution config -- have a single hash of names and aliases pointing to QIDs
    # Hash from QID to array of institution names, preferred name is first;
    # alias is last
    # primarily useful as a non repeating configuration for other hashes
    QID_TO_INSTITUTION_NAMES = {
      'Q814779'   => ['Beinecke Rare Book & Manuscript Library', 'beinecke'],
      'Q995265'   => ['Bryn Mawr College', 'brynmawr'],
      'Q63969940' => ['Burke Library at Union Theological Seminary', 'burke'],
      'Q5146808'  => ['The College of Physicians of Philadelphia'],
      'Q30257935' => ['Conception Abbey and Seminary', 'Conception Seminary College', 'conception'],
      'Q1093910'  => ['City College of New York', 'cuny', 'ccny'],
      'Q5021042'  => ['State of California', 'California State Library', 'csl'],
      'Q49088'    => ['Columbia University', 'columbia'],
      'Q49115'    => ['Cornell University', 'cornell'],
      'Q3087288'  => ['Free Library of Philadelphia', 'flp'],
      'Q1501676'  => ['General Theological Seminary', 'gts'],
      'Q5174002'  => ['Grolier Club', 'grolier'],
      'Q13371'    => ['Harvard University', 'harvard'],
      'Q1400558'  => ['Huntington Library, Art Museum, and Botanical Gardens',
                      'The Huntington Library, Art Museum, and Botanical Gardens',
                      'huntington'],
      'Q1079140'  => ['Indiana University, Bloomington', 'Indiana University', 'indiana'],
      'Q52413'    => ['University of Kansas', 'kansas'],
      'Q1976985'  => ['Nelson-Atkins Museum of Art', 'nelsonatkins'],
      'Q49210'    => ['New York University', 'nyu'],
      'Q510324'   => ['Philadelphia Museum of Art'],
      'Q21578'    => ['Princeton University', 'princeton'],
      'Q20745482' => ['Providence Public Library', 'providence'],
      'Q499451'   => ['Rutgers, The State University of New Jersey', 'rutgers'],
      'Q5090408'  => ['Science History Institute', 'Chemical Heritage Foundation', 'shi'],
      'Q1378320'  => ['Swarthmore College', 'swarthmore'],
      'Q168756'   => ['University of California, Berkeley', 'ucb'],
      'Q579968'   => ['University of Missouri', 'mizzou', 'missouri'],
      'Q766145'   => ['University of Oregon', 'oregon'],
      'Q49117'    => ['University of Pennsylvania', 'upenn', 'penn'],
      'Q49205'    => ['Wellesley College', 'wellesley'],
      'Q49112'    => ['Yale University', 'yale'],
    }.freeze

    # Reverse QID_TO_INSTITUTION_NAMES: Point from each name to the QID URL
    INSTITUTION_NAMES_TO_QID = QID_TO_INSTITUTION_NAMES.inject({}) { |hash, values|
      qid, names = values
      names.each { |name| hash.update({ name => qid }) }
      hash
    }.freeze

    # Extract all the one-word names as institution aliases; [:alnum:] -- allow unicode characters
    INSTITUTION_ALIASES = INSTITUTION_NAMES_TO_QID.keys.select { |k| k =~ %r{^[[:alnum:]]+$} }

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

    INSTITUTIONS = INSTITUTION_DS_IDS.values.uniq.freeze

    MARC_XML = :marc
    METS_XML = :mets
    TEI_XML  = :tei
    CSV      = :csv
    SOURCE_TYPES = [ MARC_XML, METS_XML, TEI_XML, CSV ].freeze
  end
end