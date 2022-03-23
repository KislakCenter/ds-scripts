require 'spec_helper'

RSpec.describe 'DS' do
  context 'transform_date_to_century' do
    it 'handles 0-99 dates' do
      expect(DS.transform_date_to_century '1400^1499').to eq '15'
    end

    it 'handles a single date' do
      expect(DS.transform_date_to_century '1325').to eq '14'
    end

    it 'handles a single-century year range' do
      expect(DS.transform_date_to_century '1325^1399').to eq '14'
    end

    it 'handles a two-century year range' do
      expect(DS.transform_date_to_century '1225^1399').to eq '13;14'
    end

    it 'handles a three-century year range' do
      expect(DS.transform_date_to_century '1125^1399').to eq '12;13;14'
    end

    it 'handles multiple dates' do
      expect(DS.transform_date_to_century '1325|1375').to eq '14|14'
    end

    it 'handles multiple date ranges' do
      expect(DS.transform_date_to_century '900^1125|1375').to eq '10;11;12|14'
    end

    it 'handles x00-x99 dates' do
      expect(DS.transform_date_to_century '1000^1099').to eq('11')
    end

    it 'handles BCE single dates' do
      expect(DS.transform_date_to_century '-1100').to eq('-11')
    end

    it 'adjusts 01-00 dates' do
      expect(DS.transform_date_to_century '1101^1200').to eq('12')
    end

    it 'adjusts 00-01 BCE dates' do
      expect(DS.transform_date_to_century '-1200^-1101').to eq('-12')
    end

    it 'handles BCE to CE dates' do
      expect(DS.transform_date_to_century '-300^200').to eq('-3;-2;-1;1;2')
    end

  end

  context 'calculate_century' do
    context 'year > 0' do
      it 'returns century 19 for year 1850' do
        expect(DS.calculate_century 1850).to eq 19
      end

      it 'returns century 19 for year 1800' do
        expect(DS.calculate_century 1800).to eq 19
      end

      it 'returns century 19 for year 1801' do
        expect(DS.calculate_century 1801).to eq 19
      end

      it 'returns century 2 for year 101' do
        expect(DS.calculate_century 101).to eq 2
      end

      it 'returns century 1 for year 100' do
        expect(DS.calculate_century 100).to eq 2
      end

      it 'returns century 1 for year 99' do
        expect(DS.calculate_century 99).to eq 1
      end
    end

    context "year == 0" do
      it 'returns century 1 for year 0' do
        expect(DS.calculate_century '0').to eq 1
      end
    end

    context 'year < 0' do
      it 'returns century -18 for year -1800' do
        expect(DS.calculate_century '-1800').to eq -18
      end

      it 'returns century -19 for year -1850' do
        expect(DS.calculate_century '-1850').to eq -19
      end

      it 'returns century -2 for year -101' do
        expect(DS.calculate_century '-101').to eq -2
      end

      it 'returns century -1 for year -100' do
        expect(DS.calculate_century '-100').to eq -1
      end

      it 'returns century -1 for year -99' do
        expect(DS.calculate_century '-99').to eq -1
      end
    end
  end
end