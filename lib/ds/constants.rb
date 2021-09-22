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

    INSTITUTION_IDS_BY_NAME = {
      'Bryn Mawr College'                         => 'https://www.wikidata.org/wiki/Q995265',
      'Chemical Heritage Foundation'              => 'https://www.wikidata.org/wiki/Q5090408',
      'City College of New York'                  => 'https://www.wikidata.org/wiki/Q1093910',
      'Columbia University'                       => 'https://www.wikidata.org/wiki/Q49088',
      'Free Library of Philadelphia'              => 'https://www.wikidata.org/wiki/Q3087288',
      'General Theological Seminary'              => 'https://www.wikidata.org/wiki/Q1501676',
      'Grolier Club'                              => 'https://www.wikidata.org/wiki/Q5174002',
      'Nelson-Atkins Museum of Art'               => 'https://www.wikidata.org/wiki/Q1976985',
      'Philadelphia Museum of Art'                => 'https://www.wikidata.org/wiki/Q510324',
      'Swarthmore College'                        => 'https://www.wikidata.org/wiki/Q1378320',
      'The College of Physicians of Philadelphia' => 'https://www.wikidata.org/wiki/Q5146808',
      'University of California, Berkeley'        => 'https://www.wikidata.org/wiki/Q168756',
      'University of Missouri'                    => 'https://www.wikidata.org/wiki/Q579968',
      'University of Pennsylvania'                => 'https://www.wikidata.org/wiki/Q49117',
      'Wellesley College'                         => 'https://www.wikidata.org/wiki/Q49205',
    }
  end
end