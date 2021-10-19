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
production_date_encoded_008
production_date
century
dated
uniform_title_240
uniform_title_240_as_recorded
uniform_title_240_agr
title_as_recorded_245
title_as_recorded_245_agr
genre_as_recorded
genre
subject_as_recorded
subject
author_as_recorded
author_as_recorded_agr
author
artist_as_recorded
artist_as_recorded_agr
artist
scribe_as_recorded
scribe_as_recorded_agr
scribe
language_as_recorded
language
former_owner_as_recorded
former_owner_as_recorded_agr
former_owner
material
material_as_recorded
physical_description
acknowledgements
}

    # TODO: Switch from QID URLs to standalone IDs
    # TODO: Look at TOML for institution config -- have a single hash of names ana aliases pointing to QIDs
    INSTITUTION_QIDS_BY_NAME = {
      'Beinecke Rare Book & Manuscript Library'   => 'https://www.wikidata.org/wiki/Q814779',
      'Bryn Mawr College'                         => 'https://www.wikidata.org/wiki/Q995265',
      'Chemical Heritage Foundation'              => 'https://www.wikidata.org/wiki/Q5090408',
      'City College of New York'                  => 'https://www.wikidata.org/wiki/Q1093910',
      'Columbia University'                       => 'https://www.wikidata.org/wiki/Q49088',
      'Cornell University'                        => 'https://www.wikidata.org/wiki/Q49115',
      'Free Library of Philadelphia'              => 'https://www.wikidata.org/wiki/Q3087288',
      'General Theological Seminary'              => 'https://www.wikidata.org/wiki/Q1501676',
      'Grolier Club'                              => 'https://www.wikidata.org/wiki/Q5174002',
      'Harvard University'                        => 'https://www.wikidata.org/wiki/Q13371',
      'Huntington Library, Art Museum, and Botanical Gardens' => 'https://www.wikidata.org/wiki/Q1400558',
      'Nelson-Atkins Museum of Art'               => 'https://www.wikidata.org/wiki/Q1976985',
      'Philadelphia Museum of Art'                => 'https://www.wikidata.org/wiki/Q510324',
      'Princeton University'                      => 'https://www.wikidata.org/wiki/Q21578',
      'Swarthmore College'                        => 'https://www.wikidata.org/wiki/Q1378320',
      'The College of Physicians of Philadelphia' => 'https://www.wikidata.org/wiki/Q5146808',
      'The Huntington Library, Art Museum, and Botanical Gardens' => 'https://www.wikidata.org/wiki/Q1400558',
      'University of California, Berkeley'        => 'https://www.wikidata.org/wiki/Q168756',
      'University of Missouri'                    => 'https://www.wikidata.org/wiki/Q579968',
      'University of Pennsylvania'                => 'https://www.wikidata.org/wiki/Q49117',
      'Wellesley College'                         => 'https://www.wikidata.org/wiki/Q49205',
      'Yale University'                           => 'https://www.wikidata.org/wiki/Q49112',
    }

    INSTITUTION_ALIASES = {
      'beinecke'   => 'Beinecke Rare Book & Manuscript Library',
      'columbia'   => 'Columbia University',
      'cornell'    => 'Cornell University',
      'flp'        => 'Free Library of Philadelphia',
      'harvard'    => 'Harvard, University',
      'huntington' => 'The Huntington Library, Art Museum, and Botanical Gardens',
      'penn'       => 'University of Pennsylvania',
      'princeton'  => 'Princeton University',
      'upenn'      => 'University of Pennsylvania',
      'wellesley'  => 'Wellesley College',
      'yale'       => 'Yale University',
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

    INSTITUTIONS = INSTITUTION_DS_IDS.values.uniq.freeze
  end
end