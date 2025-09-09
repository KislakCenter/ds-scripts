# DS Convert

RubyGem that provides scripts to transform and manage input from multiple sources to generate a DS 2.0 imports CSV. Also includes scripts to extract strings from sources for authority reconciliation.

# Requirements

* Ruby version >= 3.4.0

# Installation

Run

```
gem install ds-convert
```

## Transformation scripts

There are three main scripts:

    ds-convert          # Generate DS import CSV from member source data
    ds-recon            # Extract string values from source data for reconciliation
    ds-validate-csv     # Check DS Import CSV for values with trailing whitespace
    marc-mrc-to-xml.rb  # Utility script to conver MARC MRC files to MARC XML

The `ds-convert` script outputs a standard DS import CSV. Columns names and order are defined in `lib/ds/constants.rb` and can be access via `DS::HEADINGS`.

The `recon` script outputs a number of CSV with extracted values for names (authors, artists, scribe, former owners), places, subjects, and genres (from various vocabularies). CSVs output by `recon` have different columns according the content type.

### `ds-convert` process

Usage:

```
ds-convert convert OPTIONS MANIFEST [SOURCE_DIR]
```

For example,

```
ds-convert convert --output path/to/outputdir/output.csv ../path/to/manifest.csv
```

Given a directory containing a set of source records (MARC XML, DS 1.0
METS, OPenn TEI XML, a CSV) and a `manifest.csv` file, `ds-convert` generates a DS
import CSV for all records listed in `manifest.csv`. The output import
CSV is used by the DS Import scripts to import data into the DS
Wikibase instance.

The values found in the `manifest.csv` are described in the [DS import
manifest data
dictionary](https://docs.google.com/spreadsheets/d/195ItCa2Qg69lp0lMuVlq2eLWJzIAmWHUzDP170_af3I/edit?usp=sharing).
The DS::Manifest::ManifestValidator validates the manifest and the
designated source records. Here is a sample manifest: [manifest.csv](https://github.com/DigitalScriptorium/ds-convert/blob/main/spec/fixtures/marc_xml/manifest.csv).

### `ds-recon` process

Given a list of source files, `ds-recon` generates one or more CSVs listing reconcilable values from the sources, names, subjects, places, etc.

Usage:

```
ds-recon --source-type=TYPE genres FILES
```

Source type is one of `marc-xml`, `tei-xml`, `ds-csv`, or `ds-mets-xml`.

Example:

```
ds-recon genres --source-type=marc-xml --directory=path/to/output_dir/ path/to/marc/*.xml
```

The `ds-recon` subcommands are:

- `write-all` - output all recon CSVs
- `genres` - output `genres.csv`
- `languages` - output `languages.csv`
- `materials` - output `materials.csv`
- `names` - output `names.csv`
- `places` - output `places.csv`
- `subjects` - output `subjects.csv`
- `titles` - output `titles.csv`
- `splits` - output `splits.csv` (see below)
- `validate` - validate a recon CSV for format and well-formedness

Splits: `splits.csv` is an ad hoc list of long lines in source records that exceed the Wikibase 400-character limit for fields. When such long lines occur the data management team splits these lines into smaller chunks and adds them to the [`splits.csv`](https://github.com/DigitalScriptorium/ds-data/blob/main/terms/reconciled/splits.csv).

## Scripts folder

The `/scripts` directory contains utility scripts for managing DS data.

        scripts
        ├── collect-prototype-data.sh           # Pull together the prototype data CSV
        ├── collect-prototype-genres.sh         # Pull together all the prototype genres
        ├── collect-prototype-names.sh          # Pull together all the prototype names
        ├── collect-prototype-places.sh         # Pull together all the prototype places
        ├── collect-prototype-subjects-named.sh # Pull together all the prototype named subjects
        ├── collect-prototype-subjects.sh       # Pull together all the prototype subjects
        ├── csv_cat.rb                          # Concatenate _n_ CSVs having the same columns
        ├── ds-image-counts.rb                  # Count online images for dependent org's
        ├── get_bibids.rb                       # Grab UPenn MMSIDs from OPenn TEI files
        ├── locate-ds10-jpegs.rb                # From METS files locate JPEG images
        ├── locate-ds10-tiffs.rb                # From METS files locate TIFF images
        ├── merge-jpeg-tiff-locations.rb        # Merge JPEG and TIFF CSVS; TODO: delete?
        ├── princeton_update_bib2.rb            # Prototype data: Create a Bib2 file to match IslamicGarrettBIB1-trim.xml
        └── princeton_update_holdings.rb        # Prototype data: Create a holdings file to match IslamicGarrettBIB1-trim.xml

Locate scripts rely on METS files and image lists found in the gzipped tarball
`data/digitassets-lib-berkeley-edu.tgz`.

#### Institutions dependent on DS:

    California State Library (Sacramento and SF locations)  csl/
    City College of New York                                cuny/
    Conception Abbey and Seminary                           conception/
    General Theological Seminary                            gts/
    Grolier Club                                            grolier/
    Indiana University                                      indiana/
    New York University                                     nyu/
    Providence Public Library                               providence/
    Rutgers, The State University of New Jersey             rutgers/
    The Nelson-Atkins Museum of Art                         nelsonatkins/
    University of California, Berkeley (Bancroft;           ucb/
        Jean Gray Hargrove Music Library; Robbins
        Collection)
    University of Kansas                                    kansas/
    Wellesley                                               wellesley/

# Development

##  Requirements

* Ruby version >= 3.4.0
* bundler Ruby gem

If you need to install Ruby or a compatible version of Ruby, you can use
[rbenv][rbenv], [rvm][rvm] or the [asdf][asdf] [ruby plugin][asdf-ruby].

[rbenv]: https://github.com/rbenv/rbenv  "rbenv on github"
[rvm]:   https://rvm.io  "Ruby Version Manger home"
[asdf]: https://asdf-vm.com/guide/getting-started.html "ASDF getting started"
[asdf-ruby]: https://github.com/asdf-vm/asdf-ruby "ASDF Ruby plugin"

If you don't have the bundler gem installed run:

```shell
$ gem install bundler
```

## Setup

Clone the repository, then:

```shell
cd ds-convert
bundle install
```

Run the Rspec specs to confirm everything is working as expected:

```
bundle exec rspec
```

### Testing

This project uses rspec for testing. To run the tests:

```
bundle exec rspec
```

### Configuration

#### Institution/QID mappings

TODO: These mappings are probably no longer used. Investigate and remove if possible.

Several of the scripts rely on mappings from institution names to Wikidata QIDs
for CSV output. These have to be entered manually in `config/settings.yml`.

Wikidata QIDs for institutions are mapped to institution names in
`config/settings.yml`. These values are used to create a reverse hash,
`Constants::INSTITUTION_NAMES_TO_QID`, which maps institution names and the
one-word aliases to Wikidata QID URLs.

`config/institutions.yml`:

```yaml
---
institutions:
  Q814779:
    - Beinecke Rare Book & Manuscript Library
    - beinecke
  Q995265:
    - Bryn Mawr College
    - brynmawr
  Q63969940:
    - Burke Library at Union Theological Seminary
    - burke
```

Lists can be any length to allow for a number of variant names. The
preferred name for the institution should be first in the list, and
alias(es) should come at the end. The last item in each list should
be the preferred short name for the institution; e.g., 'beinecke',
'burke', 'penn'.

#### Reconciliation values

Reconciliation CSVs are maintained in git and loaded at runtime.

The file `config/settings.yml` defines the location of the git repository,
path to each reconciliation CSV, and key columns:

```yaml
---
recon:
  local_dir: <%= ENV['DS_DATA_DIR'] || '/tmp' %>
  git_repo: 'https://github.com/DigitalScriptorium/ds-data.git'
  git_branch: main
  git_local_name: ds-data
  iiif_manifests: iiif/legacy-iiif-manifests.csv
  legacy_ia_urls: internet_archive/legacy-ia-urls.csv
  sets:
    - name: names
      repo_path: terms/names.csv
      key_column: name
    - name: genres
      repo_path: terms/genres.csv
      key_column: term
      subset_column: vocabulary
    - name: places
      repo_path: terms/places.csv
      key_column: place_as_recorded
```

Values are:

- `sets`: each CSV set loaded by the `Recon` module
- `name`: name of each set, used by `Recon.find_set(name)`
- `repo_path`: path of the CSV file or files in the repository
