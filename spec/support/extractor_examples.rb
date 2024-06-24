# frozen_string_literal: true

RSpec.shared_examples "an extractor" do |options|
  context 'titles' do
    context 'extract_titles' do
      let(:extraction_method) { :extract_titles }
      let(:composite_type) { DS::Extractor::Title }
      it 'returns an array of Title objects' do
        expect(
          described_class.send extraction_method, record
        ).to include an_instance_of composite_type
      end
    end

    context 'extract_titles_as_recorded' do
      let(:extract_method) { :extract_titles_as_recorded }
      let(:return_type) { Array }
      let(:array_type) { String }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end

    context 'extract_titles_as_recorded_agr', unless: skip?(options, :titles_agr) do
      let(:extract_method) { :extract_titles_as_recorded_agr }
      let(:return_type) { Array }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end

    context 'extract_recon_titles' do
      let(:extract_method) { :extract_recon_titles }
      let(:return_type) { Array }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end
  end # titles

  context 'uniform_titles', unless: skip?(options, :uniform_titles) do
    context 'extract_uniform_titles_as_recorded' do
      let(:extract_method) { :extract_uniform_titles_as_recorded }
      let(:return_type) { Array }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end

    context 'extract_uniform_titles_as_recorded_agr', unless: skip?(options, :uniform_titles_agr) do
      let(:extract_method) { :extract_uniform_titles_as_recorded_agr }
      let(:return_type) { Array }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end
  end # uniform_titles

  context 'languages' do
    context 'extract_languages' do
      let(:extraction_method) { :extract_languages }
      let(:composite_type) { DS::Extractor::Language }
      it 'returns an array of Language objects' do
        expect(
          described_class.send extraction_method, record
        ).to include an_instance_of composite_type
      end
    end

    context 'extract_languages_as_recorded' do
      let(:extract_method) { :extract_languages_as_recorded }
      let(:return_type) { Array }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end

  end

  context 'materials' do
    context 'extract_materials' do
      let(:extraction_method) { :extract_materials }
      let(:composite_type) { DS::Extractor::Material }
      it 'returns an array of Material objects' do
        expect(
          described_class.send extraction_method, record
        ).to include an_instance_of composite_type
      end
    end

    context 'extract_material_as_recorded' do
      let(:extract_method) { :extract_material_as_recorded }
      let(:return_type) { String }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end
  end


  context 'names' do

    context 'authors' do
      context 'extract_authors' do
        let(:extraction_method) { :extract_authors }
        let(:composite_type) { DS::Extractor::Name }
        it 'returns an array of Name objects' do
          expect(
            described_class.send extraction_method, record
          ).to include an_instance_of composite_type
        end
      end

      context 'extract_authors_as_recorded' do
        let(:extract_method) { :extract_authors_as_recorded }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end

      context 'extract_authors_as_recorded_agr', unless: skip?(options, :authors_agr) do
        let(:extract_method) { :extract_authors_as_recorded_agr }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end

    end

    context 'artists' do
      context 'extract_artists' do
        let(:extraction_method) { :extract_artists }
        let(:composite_type) { DS::Extractor::Name }
        it 'returns an array of Name objects' do
          expect(
            described_class.send extraction_method, record
          ).to include an_instance_of composite_type
        end
      end

      context 'extract_artists_as_recorded' do
        let(:extract_method) { :extract_artists_as_recorded }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end

      context 'extract_artists_as_recorded_agr', unless: skip?(options, :artists_agr) do
        let(:extract_method) { :extract_artists_as_recorded_agr }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end
    end


    context 'scribes' do
      context 'extract_scribes' do
        let(:extraction_method) { :extract_scribes }
        let(:composite_type) { DS::Extractor::Name }
        it 'returns an array of Name objects' do
          expect(
            described_class.send extraction_method, record
          ).to include an_instance_of composite_type
        end
      end


      context 'extract_scribes_as_recorded' do
        let(:extract_method) { :extract_scribes_as_recorded }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end

      context 'extract_scribes_as_recorded_agr', unless: skip?(options, :scribes_agr) do
        let(:extract_method) { :extract_scribes_as_recorded_agr }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end
    end

    context 'former_owners' do
      context 'extract_former_owners' do
        let(:extraction_method) { :extract_former_owners }
        let(:composite_type) { DS::Extractor::Name }
        it 'returns an array of Name objects' do
          expect(
            described_class.send extraction_method, record
          ).to include an_instance_of composite_type
        end
      end


      context 'extract_former_owners_as_recorded' do
        let(:extract_method) { :extract_former_owners_as_recorded }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end

      context 'extract_former_owners_as_recorded_agr', unless: skip?(options, :former_owners_agr) do
        let(:extract_method) { :extract_former_owners_as_recorded_agr }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end
    end

    context 'other_names', unless: skip?(options, :other_names) do
      context 'extract_associated_agents' do
        let(:extraction_method) { :extract_associated_agents }
        let(:composite_type) { DS::Extractor::Name }
        it 'returns an array of Name objects' do
          expect(
            described_class.send extraction_method, record
          ).to include an_instance_of composite_type
        end
      end

      context 'extract_other_names_as_recorded' do
        let(:extract_method) { :extract_other_names_as_recorded }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end
    end

    context 'extract_recon_names' do
      let(:extract_method) { :extract_recon_names }
      let(:return_type) { Array }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end
  end # context: names

  context 'terms' do
    context 'genres', unless: skip?(options, :genres) do
      context 'extract_genres' do
        let(:extraction_method) { :extract_genres }
        let(:composite_type) { DS::Extractor::Genre }
        it 'returns an array of Genre objects' do
          expect(
            described_class.send extraction_method, record
          ).to include an_instance_of composite_type
        end
      end

      context 'extract_genres_as_recorded' do
        let(:extract_method) { :extract_genres_as_recorded }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end

      context 'extract_recon_genres' do
        let(:extract_method) { :extract_recon_genres }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end

    end

    context 'subjects' do
      context 'extract_subjects' do
        let(:extraction_method) { :extract_subjects }
        let(:composite_type) { DS::Extractor::Subject }
        it 'returns an array of Subject objects' do
          expect(
            described_class.send extraction_method, record
          ).to include an_instance_of composite_type
        end
      end

      context 'extract_all_subjects_as_recorded' do
        let(:extract_method) { :extract_all_subjects_as_recorded }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end

      context 'extract_recon_subjects' do
        let(:extract_method) { :extract_recon_subjects }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end

      context 'extract_subjects_as_recorded' do
        let(:extract_method) { :extract_subjects_as_recorded }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end
    end

    context 'named_subjects', unless: skip?(options, :named_subjects) do
      context 'extract_named_subjects' do
        let(:extraction_method) { :extract_named_subjects }
        let(:composite_type) { DS::Extractor::Subject }
        it 'returns an array of Subject objects' do
          expect(
            described_class.send extraction_method, record
          ).to include an_instance_of composite_type
        end
      end

      context 'extract_named_subjects_as_recorded' do
        let(:extract_method) { :extract_named_subjects_as_recorded }
        let(:return_type) { Array }

        it 'responds to the method' do
          expect(described_class).to respond_to extract_method
        end

        it 'returns the expected type' do
          expect(described_class.send extract_method, record).to be_a return_type
        end
      end
    end
  end # terms


  context 'places' do
    context 'extract_places' do
      let(:extraction_method) { :extract_places }
      let(:composite_type) { DS::Extractor::Place }
      it 'returns an array of Place objects' do
        expect(
          described_class.send extraction_method, record
        ).to include an_instance_of composite_type
      end
    end


    context 'extract_recon_places' do
      let(:extract_method) { :extract_recon_places }
      let(:return_type) { Array }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end


    context 'extract_production_places_as_recorded' do
      let(:extract_method) { :extract_production_places_as_recorded }
      let(:return_type) { Array }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end
  end

  context 'date' do



    context 'extract_production_date_as_recorded' do
      let(:extract_method) { :extract_production_date_as_recorded }
      let(:return_type) { Array }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record).to be_a return_type
      end
    end

    context 'extract_date_range' do
      let(:extract_method) { :extract_date_range }
      let(:return_type) { Array }

      it 'responds to the method' do
        expect(described_class).to respond_to extract_method
      end

      it 'returns the expected type' do
        expect(described_class.send extract_method, record, range_sep: '^').to be_a return_type
      end

      it 'returns an array of year-range strings' do
        expect(described_class.send extract_method, record, range_sep: '^').to all be_a String
      end
    end
  end


  context 'extract_cataloging_convention', unless: skip?(options, :cataloging_convention) do
    let(:extract_method) { :extract_cataloging_convention }
    let(:return_type) { String }

    it 'responds to the method' do
      expect(described_class).to respond_to extract_method
    end

    it 'returns the expected type' do
      expect(described_class.send extract_method, record).to be_a return_type
    end
  end

  context 'extract_physical_description' do
    let(:extract_method) { :extract_physical_description }
    let(:return_type) { Array }

    it 'responds to the method' do
      expect(described_class).to respond_to extract_method
    end

    it 'returns the expected type' do
      expect(described_class.send extract_method, record).to be_a return_type
    end
  end

  context 'extract_notes' do
    let(:extract_method) { :extract_notes }
    let(:return_type) { Array }

    it 'responds to the method' do
      expect(described_class).to respond_to extract_method
    end

    it 'returns the expected type' do
      expect(described_class.send extract_method, record).to be_a return_type
    end
  end

  context 'extract_acknowledgments' do
    let(:extract_method) { :extract_acknowledgments }
    let(:return_type) { Array }

    it 'responds to the method' do
      expect(described_class).to respond_to extract_method
    end

    it 'returns the expected type' do
      expect(described_class.send extract_method, record).to be_a return_type
    end
  end

end
