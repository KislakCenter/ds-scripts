# ReadMe

Scripts to transform and manage input from multiple sources for DS 2.0 CSV.
Also includes scripts for parsing METS and locating files for legacy Digital
Scriptorium.

## Transformation scripts

There are three main scripts:

    bin/
    ├── ds-convert          # Convert catalog files to DS CSV
    ├── marc-mrc-to-xml.rb  # Extract MARC XML from MARC MRC/DAT
    └── recon               # Extract conciliation CSVs from catalog file

Here `catalog file` is any set of XML or CSV input files from a DS member
institution: MARC XML, OPenn TEI XML, DS 1.0 legacy METS XMl, or CSV
(forthcoming).

The `ds-convert` script outputs a standard DS CSV. All output CSV files have
the same columns in the same order. Columns names and order are set in
`lib/ds/constants.rb` and can be access via `DS::HEADINGS`.

The `recon` script outputs a number of CSV with extracted values for names
(authors, artists, scribe, former owners), places, subjects, and genres (from
various vocabularies). CSVs output by `recon` have different columns according
the content type.

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

# Requirements

* Ruby version >= 2.6.1 and <= 3.0
* bundler Ruby gem

These scripts were written with Ruby version 2.6.1. They should run with Ruby
`>= 2.6.1` and `< 3.0.0` (and may run with Ruby `~> 3.0`, but they haven't been
tested with it).

If you need to install Ruby or a compatible version of Ruby, you can use
[rbenv][rbenv] (recommended) or [rvm][rvm].

[rbenv]: https://github.com/rbenv/rbenv  "rbenv on github"
[rvm]:   https://rvm.io                  "Ruby Version Manger home"

```shell
$ gem install bundler
```

# Installation

Clone the repository, and then from the repository folder, run bundler.

```shell
$ bundle install
```

All scripts are in the `scripts` directory. It's best to run them with
bundler; e.g.,

```shell
$ bundle exec ruby scripts/ds-image-counts.rb
```

### Configuration

#### Institution/QID mappings

Several of the scripts rely on mappings from institution names to Wikidata QIDs
for CSV output. These have to be entered manually in `config/institutions.yml`.

Wikidata QIDs for institutions are mapped to institution names in
`config/institutions.yml`. These values are used to create a reverse hash,
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

Reconciliation CSVs are maintained in git and loaded at runtime from a git
repository in the `/data` directory.

The file `config/recon.yml` defines the location of the git repository,
path to each reconciliation CSV, and key columns:

```yaml
---
recon:
  git_repo: 'https://github.com/DigitalScriptorium/ds-data.git'
  git_branch: 'feature/1-directory-for-reconciliations'
  git_local_name: 'ds-data'
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
- `repo_path`: path of the CSV file in the repository
- `key_column`: column containing the reconciled values; e.g., personal names, place names, subject terms
- `subset_column`: name of the column for subsets within the data; e.g., the vocabulary column for genres
