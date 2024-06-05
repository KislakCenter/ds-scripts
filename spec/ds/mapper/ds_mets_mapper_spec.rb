# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Mapper::DSMetsMapper' do

  let(:manifest_csv) { parse_csv <<~EOF
    holding_institution_wikidata_qid,holding_institution_wikidata_label,ds_id,source_data_type,filename,holding_institution_institutional_id,institutional_id_location_in_source,call_number,link_to_institutional_record,record_last_updated,title,iiif_manifest_url,manifest_generated_at
    Q1976985,The Nelson-Atkins Museum of Art ,,ds-mets,ds_mets-nelson-atkins-kg40.xml,KG 40,"/mets:mets[./mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type = 'local' and ./text() = 'ID_PLACEHOLDER']]",KG 40,https://archive.org/details/KG40_46,2016-09-13T08:51:34,"Book of Hours, excerpt Hours of the Cross",https://iiif.archivelab.org/iiif/images_KG40_46/manifest.json,2023-12-16T12:51:52-0500
    EOF
  }
  let(:xml_dir) { fixture_path 'ds_mets_xml' }
  let(:manifest_path) { File.join xml_dir, 'manifest.csv' }
  let(:manifest_row) { manifest_csv.first }
  let(:manifest) { DS::Manifest::Manifest.new manifest_path, xml_dir }
  let(:entry) { DS::Manifest::Entry.new manifest_row, manifest }

  let(:timestamp) { Time.now }
  let(:mapper) {
    DS::Mapper::DSMetsMapper.new(
      source_dir: xml_dir,
      timestamp: timestamp
    )
  }

  let(:extractor) {  DS::Extractor::DsMetsXml }

  let(:subject) { mapper}
  let(:source_path) { File.join xml_dir, entry.filename }

  context 'mapper implementation' do
    except = %i[
        extract_cataloging_convention
        extract_uniform_titles_as_recorded
        extract_uniform_titles_as_recorded_agr
        extract_titles_as_recorded_agr
        extract_authors_as_recorded_agr
        extract_artists_as_recorded_agr
        extract_former_owners_as_recorded_agr
        extract_scribes_as_recorded_agr
        extract_genres_as_recorded
        extract_genre_vocabulary
    ]

    it_behaves_like 'an extractor mapper', except
  end

  context 'initialize' do
    it 'creates a mapper' do
      mapper = DS::Mapper::DSMetsMapper.new source_dir: xml_dir, timestamp: timestamp
      expect(mapper).to be_a DS::Mapper::DSMetsMapper
    end
  end

  context '#map_record' do
    let(:expected_map) {
      {
        ds_id:                              nil,
        date_added:                         nil,
        date_last_updated:                  nil,
        dated:                              false,
        cataloging_convention:              "ds-mets",
        source_type:                        "ds-mets",
        holding_institution:                "Q1976985",
        holding_institution_as_recorded:    "The Nelson-Atkins Museum of Art ",
        holding_institution_id_number:      "KG 40",
        holding_institution_shelfmark:      "KG 40",
        link_to_holding_institution_record: "https://archive.org/details/KG40_46",
        iiif_manifest:                      "https://iiif.archivelab.org/iiif/images_KG40_46/manifest.json",
        production_place_as_recorded:       "France, Northern",
        production_place:                   "http://vocab.getty.edu/tgn/1000070",
        production_place_label:             "France",
        production_date_as_recorded:        "s. XV; 1400-1499",
        production_date:                    "1400^1499",
        century:                            "15",
        century_aat:                        "http://vocab.getty.edu/aat/300404465",
        title_as_recorded:                  "Book of Hours, excerpt Hours of the Cross",
        title_as_recorded_agr:              "",
        uniform_title_as_recorded:          "",
        uniform_title_agr:                  "",
        standard_title:                     "Book of Hours",
        genre_as_recorded:                  "",
        genre:                              "",
        genre_label:                        "",
        subject_as_recorded:                "Catholic Church--Liturgy--Texts.|Manuscripts, Latin (Medieval and modern)--Massachusetts--Northampton.",
        subject:                            "http://id.worldcat.org/fast/531720;http://id.worldcat.org/fast/1000579;http://id.worldcat.org/fast/1423705|",
        subject_label:                      "Catholic Church;Liturgics;Texts|",
        author_as_recorded:                 "Catholic Church.",
        author_as_recorded_agr:             "",
        author:                             "",
        author_wikidata:                    "Q12345",
        author_instance_of:                 "organization",
        author_label:                       "Catholic Church",
        artist_as_recorded:                 "Hans Wertinger, also called Hans Schwab von Wertinger (1465/70–1533), of Landshut, or his workshop",
        artist_as_recorded_agr:             "",
        artist:                             "",
        artist_label:                       "",
        artist_wikidata:                    "",
        artist_instance_of:                 "",
        scribe_as_recorded:                 "Pynchebek",
        scribe_as_recorded_agr:             "",
        scribe:                             "",
        scribe_label:                       "",
        scribe_wikidata:                    "",
        scribe_instance_of:                 "",
        associated_agent_as_recorded:       "William Skrene|John Quynton|John Blecche and his wife, Mary",
        associated_agent_as_recorded_agr:   "",
        associated_agent:                   "",
        associated_agent_instance_of:       "||",
        associated_agent_label:             "||",
        associated_agent_wikidata:          "||",
        language_as_recorded:               "Latin",
        language:                           "Q397",
        language_label:                     "Latin",
        former_owner_as_recorded:
                                            "Lewis Gould purchased from Galena Books from the Los Angeles Book Fair. Gift of Lewis Gould to the Nelson-Atkins Museum of Art in 2015 in his wife's memory.|SPLIT: Long ownership: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ligula ullamcorper malesuada proin libero. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Parturient montes nascetur ridiculus mus. Augue neque gravida in fermentum et sollicitudin ac orci. Ullamcorper sit amet risus nullam eget felis eget nunc. Egestas sed sed risus pretium quam vulputate dignissim. Viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat. Sagittis vitae et leo duis. Ut sem viverra aliquet eget.",
        former_owner_as_recorded_agr:       "",
        former_owner:                       "",
        former_owner_label:                 "|",
        former_owner_wikidata:              "|",
        former_owner_instance_of:           "|", material_as_recorded: "parchment, semi-translucent",
        material:                           "http://vocab.getty.edu/aat/300011851",
        material_label:                     "parchment",
        physical_description:
                                            "Binding: Not bound.|Binding: Long MS description: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ligula ullamcorper malesuada proin libero. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Parturient montes nascetur ridiculus mus. Augue neque gravida in fermentum et sollicitudin ac orci. Ullamcorper sit amet risus nullam eget felis eget nunc. Egestas sed sed risus pretium quam vulputate dignissim. Viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat. Sagittis vitae et leo duis. Ut sem viverra aliquet eget.|Figurative details, One leaf: Long part description: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ligula ullamcorper malesuada proin libero. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Parturient montes nascetur ridiculus mus. Augue neque gravida in fermentum et sollicitudin ac orci. Ullamcorper sit amet risus nullam eget felis eget nunc. Egestas sed sed risus pretium quam vulputate dignissim. Viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat. Sagittis vitae et leo duis. Ut sem viverra aliquet eget.|Figurative details, One leaf: Physical details note.|Other decoration, One leaf: Physical description note.|Number of scribes, One leaf: number of scribes.|Other decoration, One leaf: Border 70 x 37 mm gold background. Fifteen lettered lines in Latin in brown ink with rubricated capitals. Recto, right margin: narcissus, 2 strawberries, violet, 2 strawberries. Verso, left margin: quadrifoliate blue flower, red and pink quadrifoliate flower, sweet pea(?), narcissus, sweet pea, pink and red blossom. Two 2-line initials (recto, verso) with light blue ground, dark blue letter with gold flourishing. Two 1-line initials on verso; gold letter on red ground.|Number of scribes, One leaf: 1.|Script, One leaf: Script note.|Music, One leaf: Medium note.|Layout, One leaf: Technique note.|Watermarks, One leaf: Marks note.",
        note:
                                            "Manuscript note: Untyped note.|Manuscript note: Long MS note: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ligula ullamcorper malesuada proin libero. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Parturient montes nascetur ridiculus mus. Augue neque gravida in fermentum et sollicitudin ac orci. Ullamcorper sit amet risus nullam eget felis eget nunc. Egestas sed sed risus pretium quam vulputate dignissim. Viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat. Sagittis vitae et leo duis. Ut sem viverra aliquet eget.|Bibliography: Bibliography.|One leaf: Top margin, recto and verso: Of. de la Croix.|One leaf: Untyped part note.|One leaf: Long part note: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ligula ullamcorper malesuada proin libero. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Parturient montes nascetur ridiculus mus. Augue neque gravida in fermentum et sollicitudin ac orci. Ullamcorper sit amet risus nullam eget felis eget nunc. Egestas sed sed risus pretium quam vulputate dignissim. Viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat. Sagittis vitae et leo duis. Ut sem viverra aliquet eget.|One leaf: Untyped text note.|One leaf: Long text note: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ligula ullamcorper malesuada proin libero. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Parturient montes nascetur ridiculus mus. Augue neque gravida in fermentum et sollicitudin ac orci. Ullamcorper sit amet risus nullam eget felis eget nunc. Egestas sed sed risus pretium quam vulputate dignissim. Viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat. Sagittis vitae et leo duis. Ut sem viverra aliquet eget.|Status of text, One leaf: Condition note.|Incipit, One leaf: Text content note.|Explicit, One leaf: Text abstract.|f. 1r: Untyped page note.|f. 1v: Verso.|f. 1v: Long page note: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ligula ullamcorper malesuada proin libero. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Parturient montes nascetur ridiculus mus. Augue neque gravida in fermentum et sollicitudin ac orci. Ullamcorper sit amet risus nullam eget felis eget nunc. Egestas sed sed risus pretium quam vulputate dignissim. Viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat. Sagittis vitae et leo duis. Ut sem viverra aliquet eget.|Incipit, f. 1v: Page content note.|Explicit, f. 1v: Page abstract.",
        acknowledgements:
                                            "We are grateful to Brother Thomas Sullivarn, O.S.B., for providing the identification of the text, and to Linda Ehrsam Voigts for the physical description.|MS acknowledgement.|Long acknowledgement: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ligula ullamcorper malesuada proin libero. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Parturient montes nascetur ridiculus mus. Augue neque gravida in fermentum et sollicitudin ac orci. Ullamcorper sit amet risus nullam eget felis eget nunc. Egestas sed sed risus pretium quam vulputate dignissim. Viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat. Sagittis vitae et leo duis. Ut sem viverra aliquet eget.|One leaf: Part acknowledgement.|One leaf: Text acknowledgement.|f. 1r: Page acknowledgement.",
        data_processed_at:                  be_some_kind_of_date_time,
        data_source_modified:               "2016-09-13T08:51:34",
        source_file:                        "ds_mets-nelson-atkins-kg40.xml"
      }
    }

    it 'maps a record' do
      expect(mapper.map_record entry).to match expected_map
    end
  end

end
