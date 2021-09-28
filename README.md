# ReadMe

Scripts to transform and manage input from multiple sources for DS 2.0 CSV.

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
