# ReadMe

Scripts to transform and manage input from multiple sources for DS 2.0 CSV.
Also includes scripts for parsing METS and locating files for legacy Digital
Scriptorium.

## Transformation scripts

There are three transformation scripts:

    bin/
    ├── ds1-mets-to-ds.rb    # Convert Digital Scriptorium METS XML
    ├── marc-mrc-to-xml.rb   # Extract MARC XML from MARC MRC/DAT
    ├── marc-xml-to-ds.rb    # Convert MARC XML
    └── openn-tei-to-ds.rb   # Convert OPenn TEI XML

All scripts take a list of XML files as arguments and output a CSV file with
standard columns. By default the name of the output file is `output.csv`, but an
alternate name and path can be specified with the `-o, --output-csv=` option.

All output CSV files have the same columns in the same order. Columns names and
order are set in `lib/ds/constants.rb` and can be access via `DS::HEADINGS`.

## Legacy Digital Scriptorium data scripts

There are three scripts for working with Digital Scriptorium images. They parse
METS files and scrape the current DS for _only those institutions that depend on
DS for cataloging and image hosting_. For this list, see below.

    ├── collect-protoptype-data.sh  # Pull together all the prototype CSV
    ├── ds-image-counts.rb          # Count online images for dependent org's
    ├── locate_ds10_jpegs.rb        # From METS files locate JPEG images
    └── sheet.rb                    # From METS files locate TIFF images

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