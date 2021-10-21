#!/usr/bin/env bash

###############################################################################
#
# Script to pull together in a single CSV data for the DS 2.0 prototype.
#
###############################################################################
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TMP_DIR=${SCRIPT_DIR}/../tmp
[[ -e ${TMP_DIR} ]] || mkdir -v ${TMP_DIR} # Create TMP_DIR if it doesn't exist

####################
# CONFIGURATION VARS
####################
# Legacy METS for institutions dependent on DS for cataloging; the folder names in data/digitalassets.lib.berkeley.edu/ds/
LEGACY_INSTS="conception csl cuny grolier gts indiana kansas nelsonatkins nyu providence rutgers ucb wellesley"
# These are the folders in data/prototype-data/ containing MARC XML
MARC_INSTS="penn cornell columbia burke"

##############
# Pre-run test
##############
if [[ -e ${SCRIPT_DIR}/../data/digitalassets.lib.berkeley.edu/ds ]]; then
  : # do nothing; we the METS files are available
else
  echo "ERROR: METS folders not found: '${SCRIPT_DIR}/../data/digitalassets.lib.berkeley.edu/ds'" >&2
  echo "Please: unzip ${SCRIPT_DIR}/../data/digitalassets-lib-berkeley-edu.tgz to ${SCRIPT_DIR}/../data" >&2
  echo "Run: " >&2
  echo "    tar xf ${SCRIPT_DIR}/../data/digitalassets-lib-berkeley-edu.tgz --directory ${SCRIPT_DIR}/../data" >&2
  exit 1
fi

################
# DS legacy METS
################
# the first 50 records for each of the legacy institutions; 450 files total
files=$(for x in ${LEGACY_INSTS}; do find ${SCRIPT_DIR}/../data/digitalassets.lib.berkeley.edu/ds/${x}/mets -name \*.xml | sort | head -50; done)
# Convert all 450 to CSV format
bundle exec ruby ${SCRIPT_DIR}/../bin/ds1-mets-to-ds.rb -o ${TMP_DIR}/legacy.csv $files

##########
# MARC XML
##########
# Run through the MARC_INSTS and output a CSV for each to TMP_DIR
for inst in ${MARC_INSTS}
do
  bundle exec ruby ${SCRIPT_DIR}/../bin/marc-xml-to-ds.rb --institution ${inst} -o ${TMP_DIR}/${inst}.csv ${SCRIPT_DIR}/../data/prototype-data/${inst}/*.xml
done

#######################
# Combine in single CSV
#######################
# list of all of the CSVs: legacy.csv penn.csv [...]
CSVS=$(for x in legacy ${MARC_INSTS}; do echo "${x}.csv"; done)
(
  cd $TMP_DIR

  # create a file with the header (=first line of legacy.csv)
  head -1 legacy.csv > combined-ds.csv
  # append all but first line of all the CSVs to combined-ds.csv
  tail -q -n +2 ${CSVS} >> combined-ds.csv
)

echo "Wrote: ${TMP_DIR}/combined-ds.csv"
