require 'spec_helper'

describe Recon do

  let(:data_dir) { fixture_path 'ds-data'  }
  let(:genres_csv) { File.join data_dir, 'terms', 'reconciled', 'genres.csv' }
  let(:languages_csv) { File.join data_dir, 'terms', 'reconciled', 'languages.csv' }
  let(:materials_csv) { File.join data_dir, 'terms', 'reconciled', 'materials.csv' }
  let(:named_subjects_csv) { File.join data_dir, 'terms', 'reconciled', 'named-subjects.csv' }
  let(:names_csv) { File.join data_dir, 'terms', 'reconciled', 'names.csv' }
  let(:places_csv) { File.join data_dir, 'terms', 'reconciled', 'places.csv' }
  let(:subjects_csv) { File.join data_dir, 'terms', 'reconciled', 'subjects.csv' }
  let(:titles_csv) { File.join data_dir, 'terms', 'reconciled', 'titles.csv' }


  context '.lookup' do
    context 'genres' do
      let(:recons_csv) { genres_csv }
      let(:set_name) { :genres }
      let(:key_values) { ['term with .', 'somevocab'] }
      let(:expected_label) { 'Term With' }
      let(:expected_url) { 'http://vocab.getty.edu/tgn/term-with' }
      let(:expected_ds_qid) { 'Q12345' }

      it 'returns the expected label' do
        expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
      end

      it 'returns the expected url' do
        expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
      end

      it 'returns the expected ds_qid' do
        expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
      end
    end

    context 'titles' do
      let(:recons_csv) { titles_csv }
      let(:set_name) { :titles }
      let(:key_values) { ['Title', 'Uniform title'] }
      let(:expected_label) { 'Standard title' }
      let(:expected_ds_qid) { 'QTITLE' }

      it 'returns the expected label' do
        expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
      end

      it 'returns the expected ds_qid' do
        expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
      end
    end

    context 'subjects' do
      let(:recons_csv) { subjects_csv }
      let(:set_name) { :subjects }
      context "with distinct subfield_codes" do

        context 'subfield_codes a--x--y' do
          let(:expected_label) { 'Subject--2--auth--label' }
          let(:expected_url) { 'http://some.url/subject2' }
          let(:expected_ds_qid) { 'QSUBJ2' }
          let(:key_values) { ['Subject with codes', 'a--x--y', 'fast'] }
          it 'returns the expected label' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
          end

          it 'returns the expected url' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
          end

          it 'returns the expected ds_qid' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
          end
        end

        context 'subfield_codes a--x--x' do
          let(:expected_label) { 'Subject--1--auth--label' }
          let(:expected_url) { 'http://some.url/subject1' }
          let(:expected_ds_qid) { 'QSUBJ1' }
          let(:key_values) { ['Subject with codes', 'a--x--x', 'fast'] }
          it 'returns the expected label' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
          end

          it 'returns the expected url' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
          end

          it 'returns the expected ds_qid' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
          end
        end

        # context 'subfield_codes a--x--y' do
        #   let(:expected_label) { 'Subject--2--auth--label' }
        #   let(:expected_url) { 'http://some.url/subject2' }
        #   let(:expected_ds_qid) { 'QSUBJ2' }
        #   let(:key_values) { ['Subject with codes', 'a--x--y', 'fast'] }
        #   it 'returns the expected label' do
        #     expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
        #   end
        #
        #   it 'returns the expected url' do
        #     expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
        #   end
        #
        #   it 'returns the expected ds_qid' do
        #     expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
        #   end
        # end
        #
        # context 'subfield_codes a--x--x' do
        #   let(:expected_label) { 'Subject--1--auth--label' }
        #   let(:expected_url) { 'http://some.url/subject1' }
        #   let(:expected_ds_qid) { 'QSUBJ1' }
        #   let(:key_values) { ['Subject with codes', 'a--x--x', 'fast'] }
        #   it 'returns the expected label' do
        #     expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
        #   end
        #
        #   it 'returns the expected url' do
        #     expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
        #   end
        #
        #   it 'returns the expected ds_qid' do
        #     expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
        #   end
        # end
      end

      context 'with distinct vocabulary' do
        context 'vocabulary aat' do
          let(:expected_label) { 'Subject--3--auth--label' }
          let(:expected_url) { 'http://some.url/subject3' }
          let(:expected_ds_qid) { 'QSUBJ3' }
          let(:key_values) { ['Subject with codes', nil, 'aat'] }
          it 'returns the expected label' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
          end

          it 'returns the expected url' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
          end

          it 'returns the expected ds_qid' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
          end
        end

        context 'vocabulary fast' do
          let(:expected_label) { 'Subject--4--auth--label' }
          let(:expected_url) { 'http://some.url/subject4' }
          let(:expected_ds_qid) { 'QSUBJ4' }
          let(:key_values) { ['Subject with codes', nil, 'fast'] }
          it 'returns the expected label' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
          end

          it 'returns the expected url' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
          end

          it 'returns the expected ds_qid' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
          end
        end
      end

    end

    context 'named subjects' do
      let(:recons_csv) { named_subjects_csv }
      let(:set_name) { :'named-subjects' }
      context "with distinct subfield_codes" do

        context 'subfield_codes a;d--v' do
          let(:expected_label) { 'Named subject1;Named subject2' }
          let(:expected_url) { 'https://some.auth/nsub1;https://some.auth/nsub2' }
          let(:expected_ds_qid) { 'QNSUB1;QNSUB2' }
          let(:key_values) { ['Named subject as recorded', 'a;d--v', 0] }
          it 'returns the expected label' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
          end

          it 'returns the expected url' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
          end

          it 'returns the expected ds_qid' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
          end
        end

        context 'subfield_codes a;d--w' do
          let(:expected_label) { 'Named subject1;Named subject3' }
          let(:expected_url) { 'https://some.auth/nsub1;https://some.auth/nsub3' }
          let(:expected_ds_qid) { 'QNSUB1;QNSUB3' }
          let(:key_values) { ['Named subject as recorded', 'a;d--w', 0] }
          it 'returns the expected label' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
          end

          it 'returns the expected url' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
          end

          it 'returns the expected ds_qid' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
          end
        end
      end

      context 'with distinct vocabulary' do
        context 'vocabulary 0' do
          let(:expected_label) { 'Named subject1;Named subject4' }
          let(:expected_url) { 'https://some.auth/nsub1;https://some.auth/nsub4' }
          let(:expected_ds_qid) { 'QNSUB1;QNSUB4' }
          let(:key_values) { ['Named subject as recorded', nil, 0] }

          it 'returns the expected label' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
          end

          it 'returns the expected url' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
          end

          it 'returns the expected ds_qid' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
          end
        end

        context 'vocabulary fast' do
          let(:expected_label) { 'Named subject1;Named subject5' }
          let(:expected_url) { 'https://some.auth/nsub1;https://some.auth/nsub5' }
          let(:expected_ds_qid) { 'QNSUB1;QNSUB5' }
          let(:key_values) { ['Named subject as recorded', nil, 'fast'] }

          it 'returns the expected label' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
          end

          it 'returns the expected url' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
          end

          it 'returns the expected ds_qid' do
            expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
          end
        end
        # context 'vocabulary fast' do
        #   let(:expected_label) { 'Subject--4--auth--label' }
        #   let(:expected_url) { 'http://some.url/subject4' }
        #   let(:expected_ds_qid) { 'QSUBJ4' }
        #   let(:key_values) { ['Subject with codes', nil, 'fast'] }
        #   it 'returns the expected label' do
        #     expect(Recon.lookup_single set_name, key_values: key_values, column: 'authorized_label').to eq expected_label
        #   end
        #
        #   it 'returns the expected url' do
        #     expect(Recon.lookup_single set_name, key_values: key_values, column: 'structured_value').to eq expected_url
        #   end
        #
        #   it 'returns the expected ds_qid' do
        #     expect(Recon.lookup_single set_name, key_values: key_values, column: 'ds_qid').to eq expected_ds_qid
        #   end
        # end
      end

    end
  end

  context '.load_set' do
    let(:set_name) { :genres }
    let(:recons_csv) { genres_csv }

    before(:each) do
      Recon.load_set set_name
    end

    it 'loads a valid set' do
      expect(Recon.load_set set_name).not_to be_empty
    end

    let(:expected_key) { %q{term with .$$somevocab} }
    it 'includes the expected key' do
      expect(Recon.load_set(set_name)).to include expected_key
    end

    let(:expected_alt_key) { %q{term with$$somevocab} }
    it 'includes the expected alt key' do
      expect(Recon.load_set(set_name)).to include expected_alt_key
    end
  end

  context '.find_set' do
    let(:set_name) { :genres }
    let(:recons_csv) { genres_csv }
    let(:expected_set) { Recon.load_set set_name }

    it 'returns the expect set' do
      expect(Recon.find_set set_name).to eq expected_set
    end
  end

  context '.build_key' do
    let(:value_array) { %w{ Foo Bar} }
    let(:expected_key) { 'foo$$bar' }
    it 'builds a key from an array of values' do
      expect(Recon.build_key value_array).to eq 'foo$$bar'
    end
  end

  context '.build_alt_key' do
    let(:key) { 'foo.$$bar' }
    let(:expected_alt_key) { 'foo$$bar' }
    it 'builds a key' do
      expect(Recon.build_alt_key key).to eq expected_alt_key
    end
  end

  context '.read_csv' do
    let(:recons_csv) { genres_csv }

    it 'reads a CSV' do
      expect(
        Recon.read_csv csv_file: recons_csv,
                       recon_type: Recon::Type::Genres,
                       data: {}
      ).not_to be_empty
    end
  end

  context '.validate!' do

    let(:valid_names_csv) { fixture_path 'names-valid.csv' }
    let(:invalid_names_csv) { fixture_path 'names-bad-columns.csv' }
    let(:valid_genres_csv) { fixture_path 'genres-valid.csv'}
    let(:invalid_genres_csv) { fixture_path 'genres-bad-columns.csv' }
    let(:invalid_genres_splits_csv) { fixture_path 'genres-bad-splits.csv' }

    it 'passes a valid names CSV' do
      expect {
        Recon.validate! :names, valid_names_csv
      }.not_to raise_error
    end

    it 'fails a names CSV missing headers' do
      expect {
        Recon.validate! :names, invalid_names_csv
      }.to raise_error /name_as_recorded.*instance_of.*authorized_label.*structured_value.*ds_qid/
    end

    it 'passes a valid genres CSV' do
      expect {
        Recon.validate! :genres, valid_genres_csv
      }.not_to raise_error
    end

    it 'fails a genres CSV missing headers' do
      expect {
        Recon.validate! :genres, invalid_genres_csv
      }.to raise_error /genre_as_recorded.*vocab.*authorized_label.*structured_value.*ds_qid/
    end
  end

end
