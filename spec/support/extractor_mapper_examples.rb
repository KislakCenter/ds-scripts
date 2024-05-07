# frozen_string_literal: true

##
# Extractor mapper examples test
#
#  - that expected message calls are made to the extractor
#  - that +mapper#map_record+ returns a hash
#  - that expected Recon calls are made
#
# The extractor mapper examples expect the invoking spec to define the
# following in +let+ statements:
#
#  - +:mapper+
#  - +:extractor+
#  - +:entry+
#
# Provide a array of of symbols as +except+ for methods not
# implemented by +extractor+ or called by +mapper+. For example,
# if a source type does not provide several values
#  available in other source types, like vernacular script versions
# of names for authors, scribes, etc.; then the extractor won't
# implement those methods and the mapper won't call them. To skip
# those methods when the 'calls all the extractor methods' example
# is run, pass them in as +except+
#
#     except = %i[
#         extract_cataloging_convention
#         extract_genres_as_recorded
#         extract_genre_vocabulary
#     ]
#
#     it_behaves_like 'an extractor mapper', except
#
# @yieldparam except [Array,nil] a list of extractor methods not
#     called by +mapper+
RSpec.shared_examples 'an extractor mapper' do |except|

  let(:extractor_methods)  {
    %i[
        extract_cataloging_convention
        extract_production_date_as_recorded
        extract_date_range
        extract_production_places_as_recorded
        extract_uniform_titles_as_recorded
        extract_uniform_titles_as_recorded_agr
        extract_titles_as_recorded
        extract_titles_as_recorded_agr
        extract_genres_as_recorded
        extract_genre_vocabulary
        extract_all_subjects_as_recorded
        extract_authors_as_recorded
        extract_authors_as_recorded_agr
        extract_artists_as_recorded
        extract_artists_as_recorded_agr
        extract_scribes_as_recorded
        extract_scribes_as_recorded_agr
        extract_languages_as_recorded
        extract_former_owners_as_recorded
        extract_former_owners_as_recorded_agr
        extract_material_as_recorded
        extract_physical_description
        extract_notes
        extract_acknowledgments
    ]
  }

  context 'DS::Mapper::BaseMapper implementation' do
    it 'implements #extract_record(entry)' do
      expect {
        mapper.extract_record entry
      }.not_to raise_error
    end

    it 'is a kind of BaseMapper' do
      expect(mapper).to be_a_kind_of DS::Mapper::BaseMapper
    end
  end

  let(:recon_classes) {
    [
      Recon::AllSubjects, Recon::Genres, Recon::Languages,
      Recon::Materials, Recon::Names, Recon::Places,
      Recon::Titles,
    ]
  }

  let(:expected_map_value_types) {
    {
      ds_id:                              be_a_ds_id.or(be_nil),
      date_added:                         be_a_date_time_string.or(be_nil),
      date_last_updated:                  be_a_date_time_string.or(be_nil),
      dated:                              be_one_of(true, false, nil, ''),
      cataloging_convention:              be_kind_of(String),
      source_type:                        be_kind_of(String),
      holding_institution:                be_kind_of(String),
      holding_institution_as_recorded:    be_kind_of(String),
      holding_institution_id_number:      be_kind_of(String),
      holding_institution_shelfmark:      be_kind_of(String),
      link_to_holding_institution_record: be_kind_of(String),
      iiif_manifest:                      be_kind_of(String),
      production_place_as_recorded:       be_kind_of(String),
      production_place:                   be_kind_of(String),
      production_place_label:             be_kind_of(String),
      production_date_as_recorded:        be_kind_of(String),
      production_date:                    be_kind_of(String),
      century:                            be_kind_of(String),
      century_aat:                        be_kind_of(String),
      title_as_recorded:                  be_kind_of(String),
      title_as_recorded_agr:              be_kind_of(String),
      uniform_title_as_recorded:          be_kind_of(String),
      uniform_title_agr:                  be_kind_of(String),
      standard_title:                     be_kind_of(String),
      genre_as_recorded:                  be_kind_of(String),
      genre:                              be_kind_of(String),
      genre_label:                        be_kind_of(String),
      subject_as_recorded:                be_kind_of(String),
      subject:                            be_kind_of(String),
      subject_label:                      be_kind_of(String),
      author_as_recorded:                 be_kind_of(String),
      author_as_recorded_agr:             be_kind_of(String),
      author:                             be_kind_of(String),
      author_wikidata:                    be_kind_of(String),
      author_instance_of:                 be_kind_of(String),
      author_label:                       be_kind_of(String),
      artist_as_recorded:                 be_kind_of(String),
      artist_as_recorded_agr:             be_kind_of(String),
      artist:                             be_kind_of(String),
      artist_label:                       be_kind_of(String),
      artist_wikidata:                    be_kind_of(String),
      artist_instance_of:                 be_kind_of(String),
      scribe_as_recorded:                 be_kind_of(String),
      scribe_as_recorded_agr:             be_kind_of(String),
      scribe:                             be_kind_of(String),
      scribe_label:                       be_kind_of(String),
      scribe_wikidata:                    be_kind_of(String),
      scribe_instance_of:                 be_kind_of(String),
      associated_agent_as_recorded:       be_kind_of(String),
      associated_agent_as_recorded_agr:   be_kind_of(String),
      associated_agent:                   be_kind_of(String),
      associated_agent_label:             be_kind_of(String),
      associated_agent_wikidata:          be_kind_of(String),
      associated_agent_instance_of:       be_kind_of(String),
      language_as_recorded:               be_kind_of(String),
      language:                           be_kind_of(String),
      language_label:                     be_kind_of(String),
      former_owner_as_recorded:           be_kind_of(String),
      former_owner_as_recorded_agr:       be_kind_of(String),
      former_owner:                       be_kind_of(String),
      former_owner_label:                 be_kind_of(String),
      former_owner_wikidata:              be_kind_of(String),
      former_owner_instance_of:           be_kind_of(String),
      material_as_recorded:               be_kind_of(String),
      material:                           be_kind_of(String),
      material_label:                     be_kind_of(String),
      physical_description:               be_kind_of(String),
      note:                               be_kind_of(String),
      acknowledgements:                   be_kind_of(String),
      data_processed_at:                  be_a_date_time_string,
      data_source_modified:               be_a_date_time_string,
      source_file:                        be_kind_of(String),
    }
  }

  context 'map_record' do

    it 'returns a hash' do
      add_stubs recon_classes, :lookup, []

      expect(mapper.map_record entry).to be_a Hash
    end

    it 'calls all the extractor methods' do
      add_stubs recon_classes, :lookup, []
      calls = extractor_methods - (except || [])

      add_expects objects: extractor, methods: calls, return_val: []
      mapper.map_record entry
    end

    it 'returns a hash with all expected keys' do
      add_stubs recon_classes, :lookup, []
      hash = mapper.map_record entry
      expect(DS::Constants::HEADINGS - hash.keys).to be_empty
    end

    it 'returns a hash with all expected value types' do
      add_stubs recon_classes, :lookup, []
      expect(mapper.map_record entry).to match expected_map_value_types
    end

    it 'returns a hash with all the import CSV columns' do
      add_stubs recon_classes, :lookup, []
      expect(mapper.map_record(entry).keys.sort).to eq DS::Constants::HEADINGS.sort
    end
  end

end
