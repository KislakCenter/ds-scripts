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

Several of the scripts rely on mappings from institution names to Wikidata QIDs
for CSV output. These have be entered manually in `lib/ds/constants.rb`.

Wikidata QIDs for institutions are mapped to institution names in
`lib/ds/constants.rb` in `QID_TO_INSTITUTION_NAMES`. This hash is used to create
a reverse hash, `INSTITUTION_NAMES_TO_QID`, which maps institution names and the
one-word aliases to Wikidata QID URLs.

        # Hash from QID to array of institution names, preferred name is first;
        # alias is last
        # primarily useful as a non repeating configuration for other hashes
        QID_TO_INSTITUTION_NAMES = {
          'Q814779'   => ['Beinecke Rare Book & Manuscript Library', 'beinecke'],
          'Q995265'   => ['Bryn Mawr College', 'brynmawr'],
          'Q63969940' => ['Burke Library at Union Theological Seminary', 'burke'],
          'Q5146808'  => ['The College of Physicians of Philadelphia'],
          'Q30257935' => ['Conception Abbey and Seminary', 'Conception Seminary College', 'conception'],
          'Q1093910'  => ['City College of New York', 'cuny', 'ccny'],
          'Q5021042'  => ['State of California', 'California State Library', 'csl'],
        # ... etc.
        }

To modify values for a QID already in the list, edit the array contents.

To add a new QID, create a new key-value pair. Make sure the new QID is not a
duplicate.

Arrays can be any length to allow for a number of variant names. The preferred
name for the institution should be first in the list, and alias(es) should come
at the end.