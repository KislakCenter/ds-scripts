# ReadMe

Scripts to transform and manage input from multiple sources for DS 2.0 CSV.
Also includes scripts for parsing METS and locating files for legacy Digital
Scriptorium.

## Transformation scripts

There are three transformation scripts:

```
scripts/
├── ds1-mets-to-ds.rb    # Convert Digital Scriptorium METS XML
├── marc-xml-to-ds.rb    # Convert MARC XML
└── openn-tei-to-ds.rb   # Convert OPenn TEI XML
```

All scripts take a list of XML files as arguments and output a CSV file with
standard columns. By default the name of the output file is `output.csv`, but an
alternate name and path can be specified with the `-o, --output-csv=` option.

All output CSV files have the same columns in the same order. Columns names and
order are set in `lib/ds/constants.rb` and can be access via

```ruby
DS::HEADINGS
```

## Legacy Digital Scriptorium data scripts

There are three scripts for working with Digital Scriptorium images. They parse
METS files and scrape the current DS for _only those institutions that depend on
DS for cataloging and image hosting_. For this list, see below.

```
scripts/
├── ds-image-counts.rb      # Count online images for dependent org's
├── locate_ds10_jpegs.rb    # From METS files locate JPEG images
└── sheet.rb                # From METS files locate TIFF images
```

Locate scripts rely on METS files and image lists found in the gzipped tarball
`data/digitassets-lib-berkeley-edu.tgz`.

#### Institutions dependent on DS:

```
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
```

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