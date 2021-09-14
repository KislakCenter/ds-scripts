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
work_as_recorded
work
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
illuminated_initials
miniatures
former_owner_as_recorded
former_owner_as_recorded_agr
former_owner
former_id_number
material
material_as_recorded
physical_description
acknowledgements
binding
folios
extent_as_recorded
dimensions
dimensions_as_recorded
decoration
}

    INSTITUTION_IDS_BY_NAME = {
      'Bryn Mawr College'                         => 'https://www.wikidata.org/wiki/Q995265',
      'Chemical Heritage Foundation'              => 'https://www.wikidata.org/wiki/Q5090408',
      'Free Library of Philadelphia'              => 'https://www.wikidata.org/wiki/Q3087288',
      'Philadelphia Museum of Art'                => 'https://www.wikidata.org/wiki/Q510324',
      'Swarthmore College'                        => 'https://www.wikidata.org/wiki/Q1378320',
      'The College of Physicians of Philadelphia' => 'https://www.wikidata.org/wiki/Q5146808',
      'University of Pennsylvania'                => 'https://www.wikidata.org/wiki/Q49117',
    }
  end
end