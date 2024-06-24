
require 'spec_helper'

RSpec.describe 'DS::Util' do
  context 'remove_brackets' do
    it "removes a leading '['" do
      expect(DS::Util.remove_brackets "[abc").to eq('abc')
    end

    it "removes the bracket from a leading ' ['" do
      expect(DS::Util.remove_brackets " [abc").to eq('abc')
    end

    it "removes a trailing ']'" do
      expect(DS::Util.remove_brackets "abc]").to eq('abc')
    end

    it "removes the bracket from a trailing '] '" do
      expect(DS::Util.remove_brackets " abc] ").to eq('abc')
    end
  end

  context 'fix_double_periods' do
    it "returns '.' for '..'" do
      expect(DS::Util.fix_double_periods '..').to eq '.'
    end

    it "returns 'a.' for 'a..'" do
      expect(DS::Util.fix_double_periods 'a..').to eq 'a.'
    end

    it "returns '... a.' for '... a..'" do
      expect(DS::Util.fix_double_periods '... a..').to eq '... a.'
    end

    it "returns 'a... a.' for 'a... a..'" do
      expect(DS::Util.fix_double_periods 'a... a..').to eq 'a... a.'
    end

    it "returns '...' for '..'" do
      expect(DS::Util.fix_double_periods '...').to eq '...'
    end

    it "returns '....' for '....'" do
      # fix_double_periods ignores a sequence of four or more periods
      expect(DS::Util.fix_double_periods '....').to eq '....'
    end
  end

  context 'unicode_normalize' do

    let(:source_string) {
      "Dawwānī, Muḥammad ibn Asʻad, 1426 or 1427-1512 or 1513"
    }
    # canonical decomposition
    let(:nfd_string) {
      source_string.unicode_normalize(:nfd)
    }

    # Canonical Decomposition, followed by Canonical Composition
    let(:nfc_string) {
      source_string.unicode_normalize(:nfc)
    }

    # Compatibility Decomposition
    let(:nfkd_string) {
      source_string.unicode_normalize(:nfkd)
    }

    # Compatibility Decomposition, followed by Canonical Composition
    let(:nfkc_string) {
      source_string.unicode_normalize(:nfkc)
    }

    it 'performs NFC normalization by default' do
      expect(DS::Util.unicode_normalize source_string).to eq(nfc_string)
    end

    it 'performs NFC normalization' do
      expect(DS::Util.unicode_normalize source_string, :nfc).to eq(nfc_string)
    end

    it 'performs NFKC normalization' do
      expect(DS::Util.unicode_normalize source_string, :nfkc).to eq(nfkc_string)
    end

    it 'performs NFKD normalization' do
      expect(DS::Util.unicode_normalize source_string, :nfkd).to eq(nfkd_string)
    end

    it 'performs NFD normalization' do
      expect(DS::Util.unicode_normalize source_string, :nfd).to eq(nfd_string)
    end
  end

  context 'normalize_string' do
    let(:source_string)  {
      "Dawwānī, Muḥammad ibn Asʻad".unicode_normalize :nfd
    }

    let(:escaped_string) { CGI.escapeURIComponent source_string }

    let(:uri) { "https://example.com/?p=#{escaped_string}" }

    let(:nfkc_uri) { uri.unicode_normalize :nfkc }

    let(:nfc_string) { source_string.unicode_normalize :nfc }

    it 'performs NFKC normalization for a URI' do
      expect(DS::Util.normalize_string uri).to eq nfkc_uri
    end

    it 'performs NFC normalization for a non URI' do
      expect(DS::Util.normalize_string source_string).to eq nfc_string
    end
  end

  context 'convert_mets_superscript' do
    let(:source_value) { 'XVI#^4/4#' }
    let(:expected) { 'XVI(4/4)' }
    let(:result) { DS::Util.convert_mets_superscript source_value }

    it 'returns the superscript value in parentheses' do
      expect(result).to eq expected
    end
  end

  context 'escape_pipes' do
    let(:source_value) {  "a b|c d" }
    let(:expected) { 'a b\|c d' }
    let(:result) { DS::Util.escape_pipes source_value }

    it 'escapes one pipe' do
      expect(result).to eq expected
    end

    it 'escapes two pipes' do
      expect(DS::Util.escape_pipes 'a b||c d').to eq 'a b\|\|c d'
    end
  end

  context 'terminate' do
    context %q{default terminator: '.' } do

      it %q{adds a period ('car' => 'car.')} do
        expect(DS::Util.terminate 'car').to eq 'car.'
      end

      it %q{adds a '.' before a double-quote ('car"' => 'car."')} do
        expect(DS::Util.terminate 'car"').to eq 'car."'
      end

      it %q{leaves in place final ','} do
        expect(DS::Util.terminate 'car,').to eq 'car,'
      end

      it %q{leaves in place final ',"'} do
        expect(DS::Util.terminate 'car,"').to eq 'car,"'
      end

      it %q{leaves in place final '?'} do
        expect(DS::Util.terminate 'car?').to eq 'car?'
      end

      it %q{adds a '?' before a double-quote ('car"' => 'car?"')} do
        expect(DS::Util.terminate 'car"', terminator: '?').to eq 'car?"'
      end
    end

    context %q{force: true} do
      it %q{forces replacement of '?' with '.' ('car?' => 'car.')} do
        expect(DS::Util.terminate 'car?', force: true).to eq 'car.'
      end

      it %q{forces replacement of '?"' with '."' ('car?"' => 'car."') } do
        expect(DS::Util.terminate 'car?"', force: true).to eq 'car."'
      end
    end

    context %q{terminator: ''} do
      it %q{removes '.' from final '."' ('car."' => 'car"')} do
        expect(DS::Util.terminate %Q{car."}, terminator: '').to eq 'car"'
      end

      it %q{removes ',' from final ',"' ('car,"' => 'car"')} do
        expect(DS::Util.terminate %Q{car,"}, terminator: '').to eq 'car"'
      end

      it %q{removes ';' from final ';"' ('car;"' => 'car"')} do
        expect(DS::Util.terminate %Q{car;"}, terminator: '').to eq 'car"'
      end

      it %q{removes ':' from final ':"' ('car:"' => 'car"')} do
        expect(DS::Util.terminate %q{car:"}, terminator: '').to eq 'car"'
      end

      it %q{removes '?' from final '?"' ('car?"' => 'car"')} do
        expect(DS::Util.terminate %q{car?"}, terminator: '').to eq 'car"'
      end

      it %q{removes '!' from final '!"' ('car!"' => 'car"')} do
        expect(DS::Util.terminate %q{car!"}, terminator: '').to eq 'car"'
      end

      it %q{removes final '.'           ('car.'  => 'car')} do
        expect(DS::Util.terminate %q{car.}, terminator: '').to eq 'car'
      end

      it %q{removes final ','           ('car,'  => 'car')} do
        expect(DS::Util.terminate %q{car,}, terminator: '').to eq 'car'
      end

      it %q{removes final ';'           ('car;'  => 'car')} do
        expect(DS::Util.terminate %q{car;}, terminator: '').to eq 'car'
      end

      it %q{removes final ';;'           ('car;;'  => 'car')} do
        expect(DS::Util.terminate %q{car;;}, terminator: '').to eq 'car'
      end

      it %q{removes final ':'           ('car:'  => 'car')} do
        expect(DS::Util.terminate %q{car:}, terminator: '').to eq 'car'
      end

      it %q{removes final '?'           ('car?'  => 'car')} do
        expect(DS::Util.terminate %q{car?}, terminator: '').to eq 'car'
      end

      it %q{removes final '!'           ('car!'  => 'car')} do
        expect(DS::Util.terminate %q{car!}, terminator: '').to eq 'car'
      end
    end

    context %q{terminator: nil} do
      it %q{removes '.' from final '."' ('car,"' => 'car"')} do
        expect(DS::Util.terminate %q{car."}, terminator: nil).to eq 'car"'
      end

      it %q{removes ',' from final ',"' ('car,"' => 'car"')} do
        expect(DS::Util.terminate %q{car,"}, terminator: nil).to eq 'car"'
      end

      it %q{removes ';' from final ':"' ('car;"' => 'car"')} do
        expect(DS::Util.terminate %q{car;"}, terminator: nil).to eq 'car"'
      end

      it %q{removes ':' from final ':"' ('car:"' => 'car"')} do
        expect(DS::Util.terminate %q{car:"}, terminator: nil).to eq 'car"'
      end

      it %q{removes '?' from final '?"' ('car?"' => 'car"')} do
        expect(DS::Util.terminate %q{car?"}, terminator: nil).to eq 'car"'
      end

      it %q{removes '!' from final '!"' ('car!"' => 'car"')} do
        expect(DS::Util.terminate %q{car!"}, terminator: nil).to eq 'car"'
      end
    end

    context %q{ellipsis} do
      it %q{ignores final '..."' with terminator: nil                             ('car..."'       => 'car..."')} do
        expect(DS::Util.terminate %q{car..."}, terminator: nil).to eq 'car..."'
      end

      it %q{ignores final '...'  with terminator: nil                             ('car...'        => 'car...')} do
        expect(DS::Util.terminate %q{car...}, terminator: nil).to eq 'car...'
      end

      it %q{ignores final '..."' with terminator: ''                              ('car..."'       => 'car..."')} do
        expect(DS::Util.terminate %q{car..."}, terminator: '').to eq 'car..."'
      end

      it %q{ignores final '...'  with terminator: ''                              ('car...'        => 'car...')} do
        expect(DS::Util.terminate %q{car...}, terminator: '').to eq 'car...'
      end

      it %q{ignores final '..."' with default terminator                          ('car..."'       => 'car..."')} do
        expect(DS::Util.terminate %q{car..."}).to eq 'car..."'
      end

      it %q{ignores final '...'  with default terminator, force: true             ('car...'        => 'car...')} do
        expect(DS::Util.terminate %q{car...}, force: true).to eq 'car...'
      end

      it %q{ignores final '..."' with default terminator, force: true             ('car..."'       => 'car..."')} do
        expect(DS::Util.terminate %q{car..."}, force: true).to eq 'car..."'
      end

      it %q{removes final '.'    with terminator: '' and medial ellipsis          ('car... door.'  => 'car... door')} do
        expect(DS::Util.terminate %q{car... door.}, terminator: '').to eq 'car... door'
      end

      it %q{replaces final '.'   with medial '...', terminator: '?', force: true  ('car... door.'  => 'car... door?')} do
        expect(DS::Util.terminate %q{car... door.}, terminator: '?', force: true).to eq 'car... door?'
      end

      it %q{replaces final '."'  with medial '...', terminator: '?', force: true  ('car... door."' => 'car... door?'")} do
        expect(DS::Util.terminate %q{car... door."}, terminator: '?', force: true).to eq 'car... door?"'
      end
    end

    context %q{pre-punctuation white space} do
      it %q{removes a space before trailing punctuation ('car :' => 'car')} do
        expect(DS::Util.terminate %q{car :}, terminator: '').to eq 'car'
      end

      it %q{removes a space before trailing punctuation and '"' ('car :"' => 'car"')} do
        expect(DS::Util.terminate %q{car :"}, terminator: '').to eq 'car"'
      end

      it %q{removes space and replaces before trailing punctuation, force: true ('car :' => 'car.')} do
        expect(DS::Util.terminate %q{car :}, terminator: '.', force: true).to eq 'car.'
      end

      it %q{removes a space and replaces before trailing punctuation and '"', force: true ('car :"' => 'car."')} do
        expect(DS::Util.terminate %q{car :"}, terminator: '.', force: true).to eq 'car."'
      end

      it %q{doesn't remove space or replace before trailing punctuation, force: false ('car :' => 'car.')} do
        expect(DS::Util.terminate %q{car :}, terminator: '.', force: true).to eq 'car.'
      end

      it %q{doesn't remove space or replace before trailing punctuation and '"', force: false ('car :"' => 'car."')} do
        expect(DS::Util.terminate %q{car :"}, terminator: '.', force: true).to eq 'car."'
      end
    end
  end

  context "clean_string" do
    let(:nfd_unicode_string) {
      "Dawwānī, Muḥammad ibn Asʻad".unicode_normalize :nfd
    }

    let(:nfc_unicode_string) {
      nfd_unicode_string.unicode_normalize :nfc
    }

    let(:source_string) {
      " [ x a|b #{nfd_unicode_string}  [] XVI#^4/4#\t\t..x ]\n"
    }

    let(:superscript_converted) { %r{XVI\(4/4\)} }

    let(:result) { DS::Util.clean_string source_string }

    it 'converts METS superscript encoding' do
      expect(result).to match superscript_converted
    end

    it 'cleans removes tabs and newlines space' do
      expect(source_string).to match %r{[\t\n]}
      expect(result).not_to match %r{[\t\n]}
    end

    it 'removes duplicate periods' do
      expect(source_string).to match %r{  +}
      expect(result).not_to match %r{  +}
    end

    it 'removes leading white space' do
      expect(source_string).to match %r{^\s}
      expect(result).not_to match %r{^\s}
    end

    it 'removes trailing white space' do
      expect(source_string).to match %r{\s$}
      expect(result).not_to match %r{\s$}
    end

    it 'removes duplicate periods' do
      expect(source_string).to include '..'
      expect(result).not_to include '..'
    end

    it 'escapes pipe' do
      expect(result).to include '\|'
    end

    it 'does not have a trailing "]"' do
      expect(source_string).to match %r{\]$}
      expect(result).not_to match %r{\]$}
    end

    it 'does not have a leading "["' do
      expect(source_string).to match %r{^\s*\[}
      expect(result).not_to match %r{^\s*\[}
    end

    it 'does not remove medial [' do
      expect(result).to include '['
    end

    it 'does not remove medial ]' do
      expect(result).to include ']'
    end

    it 'is NFC normalized' do
      expect(result).to include nfc_unicode_string
    end

    it 'removes a trailing period' do
      result = DS::Util.clean_string 'some string.', terminator: ''
      expect(result).to eq 'some string'
    end

    it 'removes a trailing period followed by a space' do
      result = DS::Util.clean_string 'some string. ', terminator: ''
      expect(result).to eq 'some string'
    end

    it 'does not remove a period after single-letter abbreviation' do
      result = DS::Util.clean_string 'work N.T.', terminator: ''
      expect(result).to eq 'work N.T.'
    end

    it 'adds a final terminator if force == true' do
      result = DS::Util.clean_string(
        'some string', terminator: '.', force: true
      )
      expect(result).to eq 'some string.'
    end

    it 'does not add a second final terminator even if force == true' do
      result = DS::Util.clean_string(
        'some string.', terminator: '.', force: true
      )
      expect(result).to eq 'some string.'
    end
  end
end
