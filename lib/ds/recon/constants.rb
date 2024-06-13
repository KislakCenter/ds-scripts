# frozen_string_literal: true

module Recon
  module Constants
    GENRE_HEADERS = %w{
      genre_as_recorded
      vocab
      source_authority_uri
      authorized_label
      structured_value
    }.freeze

   LANGUAGES_HEADERS = %w{
      language_as_recorded
      language_code
      authorized_label
      structured_value
    }.freeze

    MATERIALS_HEADERS = %w{
      material_as_recorded authorized_label structured_value
    }.freeze

    NAMES_HEADERS = %w{
      name_as_recorded
      role
      name_agr
      source_authority_uri
      instance_of
      authorized_label
      structured_value
    }.freeze

    PLACES_HEADERS = %w{
      place_as_recorded authorized_label structured_value
    }.freeze

    SUBJECT_HEADERS = %w{
      subject_as_recorded
      subfield_codes
      vocab
      source_authority_uri
      authorized_label
      structured_value
    }.freeze

    TITLE_HEADERS = %w{
      title_as_recorded
      title_as_recorded_agr
      uniform_title_as_recorded
      uniform_title_as_recorded_agr
      authorized_label
    }.freeze

  end
end
