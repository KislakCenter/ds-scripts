require 'spec_helper'

RSpec.describe 'DS' do
  context 'transform_dates_to_centuries' do
    it 'handles 0-99 dates' do
      expect(DS.transform_dates_to_centuries '1400^1499').to eq '15'
    end

    it 'handles 1-00 dates' do
      expect(DS.transform_dates_to_centuries '1401^1500').to eq '15'
    end

    it 'handles a single date' do
      expect(DS.transform_dates_to_centuries '1325').to eq '14'
    end

    it 'handles a single-century year range' do
      expect(DS.transform_dates_to_centuries '1325^1399').to eq '14'
    end

    it 'handles a two-century year range' do
      expect(DS.transform_dates_to_centuries '1225^1399').to eq '13;14'
    end

    it 'handles a three-century year range' do
      expect(DS.transform_dates_to_centuries '1125^1399').to eq '12;13;14'
    end

    it 'handles multiple dates' do
      expect(DS.transform_dates_to_centuries '1325|1375').to eq '14|14'
    end

    it 'handles multiple date ranges' do
      expect(DS.transform_dates_to_centuries '900^1125|1375').to eq '10;11;12|14'
    end

    it 'handles BCE single dates' do
      expect(DS.transform_dates_to_centuries '-1100').to eq('-11')
    end

    it 'handles a BCE-to-CE date range' do
      expect(DS.transform_dates_to_centuries '-300^200').to eq('-3;-2;-1;1;2')
    end

    it 'returns 14 for 1325' do
      expect(DS.transform_dates_to_centuries '1325').to eq '14'
    end
    it 'returns 15 for 1400^1499' do
      expect(DS.transform_dates_to_centuries '1400^1499').to eq '15'
    end
    it 'returns 15 for 1401^1500' do
      expect(DS.transform_dates_to_centuries '1401^1500').to eq '15'
    end
    it 'returns -15 for -1500^-1401' do
      expect(DS.transform_dates_to_centuries '-1500^-1401').to eq '-15'
    end
    it 'returns -15 for -1499^-1400' do
      expect(DS.transform_dates_to_centuries '-1499^-1400').to eq '-15'
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
  context 'adjust_for_century' do
    it 'returns 1325 for 1325' do
      expect(DS.adjust_for_century '1325').to eq '1325'
    end
    it 'returns 1400^1499 for 1400^1499' do
      expect(DS.adjust_for_century '1400^1499').to eq '1400^1499'
    end
    it 'returns 1401^1499 for 1401^1500' do
      expect(DS.adjust_for_century '1401^1500').to eq '1401^1499'
    end
    it 'returns -1500^-1401 for -1500^-1401' do
      expect(DS.adjust_for_century '-1500^-1401').to eq '-1500^-1401'
    end
    it 'returns -1499^-1401 for -1499^-1400' do
      expect(DS.adjust_for_century '-1499^-1400').to eq '-1499^-1401'
    end
  end

  context 'terminate' do
    context %q{default terminator: '.' } do

      it %q{adds a period ('car' => 'car.')} do
        expect(DS.terminate 'car').to eq 'car.'
      end

      it %q{adds a '.' before a double-quote ('car"' => 'car."')} do
        expect(DS.terminate 'car"').to eq 'car."'
      end

      it %q{leaves in place final ','} do
        expect(DS.terminate 'car,').to eq 'car,'
      end

      it %q{leaves in place final ',"'} do
        expect(DS.terminate 'car,"').to eq 'car,"'
      end

      it %q{leaves in place final '?'} do
        expect(DS.terminate 'car?').to eq 'car?'
      end

      it %q{adds a '?' before a double-quote ('car"' => 'car?"')} do
        expect(DS.terminate 'car"', terminator: '?').to eq 'car?"'
      end
    end

    context %q{force: true} do
      it %q{forces replacement of '?' with '.' ('car?' => 'car.')} do
        expect(DS.terminate 'car?', force: true).to eq 'car.'
      end

      it %q{forces replacement of '?"' with '."' ('car?"' => 'car."') } do
        expect(DS.terminate 'car?"', force: true).to eq 'car."'
      end
    end

    context %q{terminator: ''} do
      it %q{removes '.' from final '."' ('car."' => 'car"')} do
        expect(DS.terminate %Q{car."}, terminator: '').to eq 'car"'
      end

      it %q{removes ',' from final ',"' ('car,"' => 'car"')} do
        expect(DS.terminate %Q{car,"}, terminator: '').to eq 'car"'
      end

      it %q{removes ';' from final ';"' ('car;"' => 'car"')} do
        expect(DS.terminate %Q{car;"}, terminator: '').to eq 'car"'
      end

      it %q{removes ':' from final ':"' ('car:"' => 'car"')} do
        expect(DS.terminate %q{car:"}, terminator: '').to eq 'car"'
      end

      it %q{removes '?' from final '?"' ('car?"' => 'car"')} do
        expect(DS.terminate %q{car?"}, terminator: '').to eq 'car"'
      end

      it %q{removes '!' from final '!"' ('car!"' => 'car"')} do
        expect(DS.terminate %q{car!"}, terminator: '').to eq 'car"'
      end

      it %q{removes final '.'           ('car.'  => 'car')} do
        expect(DS.terminate %q{car.}, terminator: '').to eq 'car'
      end

      it %q{removes final ','           ('car,'  => 'car')} do
        expect(DS.terminate %q{car,}, terminator: '').to eq 'car'
      end

      it %q{removes final ';'           ('car;'  => 'car')} do
        expect(DS.terminate %q{car;}, terminator: '').to eq 'car'
      end

      it %q{removes final ';;'           ('car;;'  => 'car')} do
        expect(DS.terminate %q{car;;}, terminator: '').to eq 'car'
      end

      it %q{removes final ':'           ('car:'  => 'car')} do
        expect(DS.terminate %q{car:}, terminator: '').to eq 'car'
      end

      it %q{removes final '?'           ('car?'  => 'car')} do
        expect(DS.terminate %q{car?}, terminator: '').to eq 'car'
      end

      it %q{removes final '!'           ('car!'  => 'car')} do
        expect(DS.terminate %q{car!}, terminator: '').to eq 'car'
      end
    end

    context %q{terminator: nil} do
      it %q{removes '.' from final '."' ('car,"' => 'car"')} do
        expect(DS.terminate %q{car."}, terminator: nil).to eq 'car"'
      end

      it %q{removes ',' from final ',"' ('car,"' => 'car"')} do
        expect(DS.terminate %q{car,"}, terminator: nil).to eq 'car"'
      end

      it %q{removes ';' from final ':"' ('car;"' => 'car"')} do
        expect(DS.terminate %q{car;"}, terminator: nil).to eq 'car"'
      end

      it %q{removes ':' from final ':"' ('car:"' => 'car"')} do
        expect(DS.terminate %q{car:"}, terminator: nil).to eq 'car"'
      end

      it %q{removes '?' from final '?"' ('car?"' => 'car"')} do
        expect(DS.terminate %q{car?"}, terminator: nil).to eq 'car"'
      end

      it %q{removes '!' from final '!"' ('car!"' => 'car"')} do
        expect(DS.terminate %q{car!"}, terminator: nil).to eq 'car"'
      end
    end

    context %q{ellipsis} do
      it %q{ignores final '..."' with terminator: nil                             ('car..."'       => 'car..."')} do
        expect(DS.terminate %q{car..."}, terminator: nil).to eq 'car..."'
      end

      it %q{ignores final '...'  with terminator: nil                             ('car...'        => 'car...')} do
        expect(DS.terminate %q{car...}, terminator: nil).to eq 'car...'
      end

      it %q{ignores final '..."' with terminator: ''                              ('car..."'       => 'car..."')} do
        expect(DS.terminate %q{car..."}, terminator: '').to eq 'car..."'
      end

      it %q{ignores final '...'  with terminator: ''                              ('car...'        => 'car...')} do
        expect(DS.terminate %q{car...}, terminator: '').to eq 'car...'
      end

      it %q{ignores final '..."' with default terminator                          ('car..."'       => 'car..."')} do
        expect(DS.terminate %q{car..."}).to eq 'car..."'
      end

      it %q{ignores final '...'  with default terminator, force: true             ('car...'        => 'car...')} do
        expect(DS.terminate %q{car...}, force: true).to eq 'car...'
      end

      it %q{ignores final '..."' with default terminator, force: true             ('car..."'       => 'car..."')} do
        expect(DS.terminate %q{car..."}, force: true).to eq 'car..."'
      end

      it %q{removes final '.'    with terminator: '' and medial ellipsis          ('car... door.'  => 'car... door')} do
        expect(DS.terminate %q{car... door.}, terminator: '').to eq 'car... door'
      end

      it %q{replaces final '.'   with medial '...', terminator: '?', force: true  ('car... door.'  => 'car... door?')} do
        expect(DS.terminate %q{car... door.}, terminator: '?', force: true).to eq 'car... door?'
      end

      it %q{replaces final '."'  with medial '...', terminator: '?', force: true  ('car... door."' => 'car... door?'")} do
        expect(DS.terminate %q{car... door."}, terminator: '?', force: true).to eq 'car... door?"'
      end
    end

    context %q{pre-punctuation white space} do
      it %q{removes a space before trailing punctuation ('car :' => 'car')} do
        expect(DS.terminate %q{car :}, terminator: '').to eq 'car'
      end

      it %q{removes a space before trailing punctuation and '"' ('car :"' => 'car"')} do
        expect(DS.terminate %q{car :"}, terminator: '').to eq 'car"'
      end

      it %q{removes space and replaces before trailing punctuation, force: true ('car :' => 'car.')} do
        expect(DS.terminate %q{car :}, terminator: '.', force: true).to eq 'car.'
      end

      it %q{removes a space and replaces before trailing punctuation and '"', force: true ('car :"' => 'car."')} do
        expect(DS.terminate %q{car :"}, terminator: '.', force: true).to eq 'car."'
      end

      it %q{doesn't remove space or replace before trailing punctuation, force: false ('car :' => 'car.')} do
        expect(DS.terminate %q{car :}, terminator: '.', force: true).to eq 'car.'
      end

      it %q{doesn't remove space or replace before trailing punctuation and '"', force: false ('car :"' => 'car."')} do
        expect(DS.terminate %q{car :"}, terminator: '.', force: true).to eq 'car."'
      end
    end
  end
end