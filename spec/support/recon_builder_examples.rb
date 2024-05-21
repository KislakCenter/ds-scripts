# frozen_string_literal: true

##
# Shared examples for testing recon extraction for a given source
# type. Performs recon extraction  all recon types: +:places+,
# +:materials+, +:languages+, +:genres+, +:subjects+,
# +:named-subjects+, +:names+, +:titles+.
#
# For each recon type, the examples confirm that the each_recon method
# yields the expected recon hash.
# #
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

  context "#each_recon" do

    context ':places', unless: skip?(skips, :places) do
      let(:set_name) { :places }
      let(:recon_class) { Recon::Places }
      let(:recon_row) {
        {
          authorized_label:  "Paris",
          ds_qid:            "",
          place_as_recorded: "Paris",
          structured_value:  "http://vocab.getty.edu/tgn/paris_id"
        }
      }
      let(:terms) {
        [DS::Extractor::Place.new(as_recorded: 'Paris')]
      }

      # let(:extractor) { double('extractor') }
      it 'yields a hash' do
        recon_class.method_name.each do |meth|
          allow(extractor).to receive(meth).and_return(terms)
        end
        expect { |b| recon_builder.each_recon(set_name, &b) }.to yield_successive_args(recon_row)
      end

    end

    context ':materials', unless: skip?(skips, :materials) do
      let(:set_name) { :materials }
      let(:recon_class) { Recon::Materials }
      let(:recon_row) {
        {
          :authorized_label=>"paper",
          :ds_qid=>"",
          :material_as_recorded=>"paper",
          :structured_value=>"http://vocab.getty.edu/aat/300014109"
        }
      }
      let(:terms) {
        [DS::Extractor::Material.new(as_recorded: 'paper')]
      }

      it 'yields a hash' do
        recon_class.method_name.each do |meth|
          allow(extractor).to receive(meth).and_return(terms)
        end
        expect { |b| recon_builder.each_recon(set_name, &b) }.to yield_successive_args(recon_row)
      end
    end

    context ':languages', unless: skip?(skips, :languages) do
      let(:set_name) { :languages }
      let(:recon_class) { Recon::Languages }
      let(:recon_row) {
        {
          :authorized_label=>"Latin",
          :ds_qid=>nil,
          :language_as_recorded=>"Latin",
          :language_code=>"la",
          :structured_value=>"Q397"
        }
      }
      let(:terms) {
        [DS::Extractor::Language.new(as_recorded: 'Latin', codes: ['la'])]
      }

      it 'yields a hash' do
        recon_class.method_name.each do |meth|
          allow(extractor).to receive(meth).and_return(terms)
        end
        expect { |b| recon_builder.each_recon(set_name, &b) }.to yield_successive_args(recon_row)
      end

    end

    context ':genres', unless: skip?(skips, :genres) do
      let(:set_name) { :genres }
      let(:recon_class) { Recon::Genres }
      let(:recon_row) {
        {
          :authorized_label=>"Qur'ans",
          :ds_qid=>"",
          :genre_as_recorded=>"Qurʼans",
          :source_authority_uri=>nil,
          :structured_value=>"http://vocab.getty.edu/aat/300265128",
          :vocabulary=>"aat"
        }
      }
      let(:terms) {
        [DS::Extractor::Genre.new(as_recorded: 'Qurʼans', vocab: 'aat' )]
      }

      it 'yields a hash' do
        recon_class.method_name.each do |meth|
          allow(extractor).to receive(meth).and_return(terms)
        end
        expect { |b| recon_builder.each_recon(set_name, &b) }.to yield_successive_args(recon_row)
      end

    end

    context ':subjects', unless: skip?(skips, :subjects) do
      let(:set_name) { :subjects }
      let(:recon_class) { Recon::Subjects }

      let(:recon_row) {
        {
          subfield_codes:        "a--x",
          vocab:                 "fast",
          source_authority_uri:  "http://id.worldcat.org/fast/1175925",
          authorized_label:      "Wine and wine making--Law and legislation",
          structured_value:      "http://id.worldcat.org/fast/1175925",
          ds_qid:                "",
          subject_as_recorded:   "Wine and wine making--Law and legislation"
        }
      }
      let(:terms) {
        [
          DS::Extractor::Subject.new(
            as_recorded: 'Wine and wine making--Law and legislation',
            vocab: 'fast',
            subfield_codes: 'a--x',
            source_authority_uri: 'http://id.worldcat.org/fast/1175925'
          )
        ]
      }

      it 'yields a hash' do
        recon_class.method_name.each do |meth|
          allow(extractor).to receive(meth).and_return(terms)
        end
        expect { |b| recon_builder.each_recon(set_name, &b) }.to yield_successive_args(recon_row)
      end
    end

    context ':named-subjects', unless: skip?(skips, :'named-subjects') do
      let(:set_name) { :'named-subjects' }
      let(:recon_class) { Recon::NamedSubjects }
      let(:terms) {
        [
          DS::Extractor::Subject.new(
            as_recorded:          'Rhetorica ad Herennium',
            vocab:                'fast',
            subfield_codes:       'a',
            source_authority_uri: 'http://id.worldcat.org/fast/1357545'
          )
        ]
      }
      let(:recon_row) {
        {:subfield_codes=>"a",
         :vocab=>"fast",
         :source_authority_uri=>"http://id.worldcat.org/fast/1357545",
         :authorized_label=>"Rhetorica ad Herennium",
         :structured_value=>"http://id.worldcat.org/fast/1357545",
         :ds_qid=>"",
         :subject_as_recorded=>"Rhetorica ad Herennium"}
      }

      it 'yields a hash' do
        recon_class.method_name.each do |meth|
          allow(extractor).to receive(meth).and_return(terms)
        end
        expect { |b| recon_builder.each_recon(set_name, &b) }.to yield_successive_args(recon_row)
      end

    end

    context ':names', unless: skip?(skips, :names) do
      let(:set_name) { :names }
      let(:recon_class) { Recon::Names }
      let(:terms) {
        [
          DS::Extractor::Name.new(
            as_recorded:          'Former owner as recorded',
            role: 'former owner',
            vernacular: 'Former owner in original script',
            ref: 'http://example.com/owner_uri'
          )
        ]
      }
      let(:recon_row) {
        {:role=>"former owner",
         :name_agr=>"Former owner in original script",
         :source_authority_uri=>"http://example.com/owner_uri",
         :authorized_label=>"Former owner auth name",
         :structured_value=>"WDQIDOWNER",
         :instance_of=>"organization",
         :ds_qid=>nil,
         :name_as_recorded=>"Former owner as recorded"}
      }

      it 'yields a hash' do
        recon_class.method_name.each do |meth|
          allow(extractor).to receive(meth).and_return(terms)
        end
        expect { |b| recon_builder.each_recon(set_name, &b) }.to yield_successive_args(recon_row)
      end

    end

    context ':titles', unless: skip?(skips, :titles) do
      let(:set_name) { :titles }
      let(:recon_class) { Recon::Titles }

      let(:recon_row) {
        {:title_as_recorded_agr=>"Title in vernacular",
         :uniform_title_as_recorded=>"Uniform title",
         :uniform_title_as_recorded_agr=>"Uniform title in vernacular",
         :authorized_label=>"Standard title",
         :ds_qid=>"",
         :title_as_recorded=>"Title"}
      }
      let(:terms) {
        [DS::Extractor::Title.new(
          as_recorded: 'Title', vernacular: 'Title in vernacular',
          uniform_title: 'Uniform title',
          uniform_title_vernacular: 'Uniform title in vernacular'
        )]
      }

      it 'yields a hash' do
        recon_class.method_name.each do |meth|
          allow(extractor).to receive(meth).and_return(terms)
        end
        expect { |b| recon_builder.each_recon(set_name, &b) }.to yield_successive_args(recon_row)
      end
    end
  end

end
