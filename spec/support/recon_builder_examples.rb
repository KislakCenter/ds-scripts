# frozen_string_literal: true

##
# Shared examples for testing recon extraction for a given source
# type. Performs recon extraction and lookups for all recon types:
# +:places+, +:materials+, +:languages+, +:genres+, +:subjects+,
# +:named-subjects+, +:names+, +:titles+.
#
# For each recon type, the following are tested:
#
# - Initialization
# - that +#extract_recons+ returns an Array
# - that +#extract_recons+ returns a non-empty Array
# - that +#extract_recons+ returns an array of hashes
# - that +#extract_recons+ returns an 2-D array with the correct number of columns in each row
# - that +#write_csv+ creates a non-empty CSV for each recon type
#
# the calling context must define the following via let statements
#
# - +:source_type+
# - +:files+
# - +:out_dir+
# - +:recon_builder+
#
# Not all source types define all recon types. To skip a particular
# recon type for a source type, pass in an array of symbols of types
# to skip; e.g,
#
#     skips = %i{ genres named-subjects }
#     it_behaves_like 'a ReconBuilder', skips
#
RSpec.shared_examples 'a ReconBuilder' do |skips|

  def skip? *skips, set_name
    return unless skips.present?
    return unless set_name.present?
    skips.include? set_name
  end

  context 'initialize' do
    it 'creates a ReconBuilder' do
      expect(
        Recon::ReconBuilder.new source_type: source_type, files: files, out_dir: out_dir
      ).to be_a Recon::ReconBuilder
    end
  end

  context "#extract_recons" do

    context ':places', unless: skip_example?(skips, :places) do
      let(:set_name) { :places }
      let(:recon_class) { Recon::Places }
      it 'returns an array' do
        expect(recon_builder.extract_recons set_name).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons set_name).not_to be_empty
      end

      it 'returns an array of hashes' do
        expect(recon_builder.extract_recons set_name).to all be_a Hash
      end

      let(:headers) { recon_class.csv_headers }
      it 'returns the hashes with the expected headers' do
        expect(recon_builder.extract_recons set_name).to all have_columns headers
      end
    end

    context ':materials', unless: skip_example?(skips, :materials) do
      let(:set_name) { :materials }
      let(:recon_class) { Recon::Materials }
      it 'returns an array' do
        expect(recon_builder.extract_recons set_name).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons set_name).not_to be_empty
      end

      it 'returns an array of hashes' do
        expect(recon_builder.extract_recons set_name).to all be_a Hash
      end

      let(:headers) { recon_class.csv_headers }
      it 'returns the hashes with the expected headers' do
        expect(recon_builder.extract_recons set_name).to all have_columns headers
      end
    end

    context ':languages', unless: skip_example?(skips, :languages) do
      let(:set_name) { :languages }
      let(:recon_class) { Recon::Languages }

      it 'returns an array' do
        expect(recon_builder.extract_recons set_name).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons set_name).not_to be_empty
      end

      it 'returns an array of hashes' do
        expect(recon_builder.extract_recons set_name).to all be_a Hash
      end

      let(:headers) { recon_class.csv_headers }
      it 'returns the hashes with the expected headers' do
        expect(recon_builder.extract_recons set_name).to all have_columns headers
      end
    end

    context ':genres', unless: skip_example?(skips, :genres) do
      let(:set_name) { :genres }
      let(:recon_class) { Recon::Genres }

      it 'returns an array' do
        expect(recon_builder.extract_recons set_name).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons set_name).not_to be_empty
      end

      it 'returns an array of hashes' do
        expect(recon_builder.extract_recons set_name).to all be_a Hash
      end

      let(:headers) { recon_class.csv_headers }
      it 'returns the hashes with the expected headers' do
        expect(recon_builder.extract_recons set_name).to all have_columns headers
      end
    end

    context ':subjects', unless: skip_example?(skips, :subjects) do
      let(:set_name) { :subjects }
      let(:recon_class) { Recon::Subjects }

      it 'returns an array' do
        expect(recon_builder.extract_recons set_name).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons set_name).not_to be_empty
      end

      it 'returns an array of hashes' do
        expect(recon_builder.extract_recons set_name).to all be_a Hash
      end

      let(:headers) { recon_class.csv_headers }
      it 'returns the hashes with the expected headers' do
        expect(recon_builder.extract_recons set_name).to all have_columns headers
      end
    end

    context ':named-subjects', unless: skip_example?(skips, :'named-subjects') do
      let(:set_name) { :'named-subjects' }
      let(:recon_class) { Recon::NamedSubjects }

      it 'returns an array' do
        expect(recon_builder.extract_recons set_name).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons set_name).not_to be_empty
      end

      it 'returns an array of hashes' do
        expect(recon_builder.extract_recons set_name).to all be_a Hash
      end

      let(:headers) { recon_class.csv_headers }
      it 'returns the hashes with the expected headers' do
        expect(recon_builder.extract_recons set_name).to all have_columns headers
      end
    end

    context ':names', unless: skip_example?(skips, :names) do
      let(:set_name) { :names }
      let(:recon_class) { Recon::Names }

      it 'returns an array' do
        expect(recon_builder.extract_recons set_name).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons set_name).not_to be_empty
      end

      it 'returns an array of hashes' do
        expect(recon_builder.extract_recons set_name).to all be_a Hash
      end

      let(:headers) { recon_class.csv_headers }
      it 'returns the hashes with the expected headers' do
        expect(recon_builder.extract_recons set_name).to all have_columns headers
      end
    end

    context ':titles', unless: skip_example?(skips, :titles) do
      let(:set_name) { :titles }
      let(:recon_class) { Recon::Titles }

      it 'returns an array' do
        expect(recon_builder.extract_recons set_name).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons set_name).not_to be_empty
      end

      it 'returns an array of hashes' do
        expect(recon_builder.extract_recons set_name).to all be_a Hash
      end

      let(:headers) { recon_class.csv_headers }
      it 'returns the hashes with the expected headers' do
        expect(recon_builder.extract_recons set_name).to all have_columns headers
      end
    end
  end

  context '#write_csv' do
    context :titles do
      let(:set_name) { :titles }

      it "writes the CSV" do
        expect { recon_builder.write_csv set_name }.not_to raise_error
      end
    end

    context :names, unless: skip_example?(skips, :names) do
      let(:set_name) { :names }

      it "writes the CSV" do
        expect { recon_builder.write_csv set_name }.not_to raise_error
      end
    end

    context :materials, unless: skip_example?(skips, :materials) do
      let(:set_name) { :materials }

      it "writes the CSV" do
        expect { recon_builder.write_csv set_name }.not_to raise_error
      end
    end

    context :genres, unless: skip_example?(skips, :genres) do
      let(:set_name) { :genres }

      it "writes the CSV" do
        expect { recon_builder.write_csv set_name }.not_to raise_error
      end
    end

    context :subjects, unless: skip_example?(skips, :subjects) do
      let(:set_name) { :subjects }

      it "writes the CSV" do
        expect { recon_builder.write_csv set_name }.not_to raise_error
      end
    end

    context :'named-subjects', unless: skip_example?(skips, :'named-subjects') do
      let(:set_name) { :'named-subjects' }

      it "writes the CSV" do
        expect { recon_builder.write_csv set_name }.not_to raise_error
      end
    end

    context :languages, unless: skip_example?(skips, :languages) do
      let(:set_name) { :languages }

      it "writes the CSV" do
        expect { recon_builder.write_csv set_name }.not_to raise_error
      end
    end
  end
end
