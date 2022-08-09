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
MARC_INSTS="penn cornell columbia burke oregon princeton hrc"
# TEI
TEI_INSTS="flp"

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

#################################
# Update the recon files from git
#################################
${SCRIPT_DIR}/../bin/recon recon-update

# use the same output directory and skip the calls to git
recon_opts=(--directory ${TMP_DIR} --skip-recon-update)

################
# DS legacy METS
################
# the first 100 records for each of the legacy institutions
files=$(for x in ${LEGACY_INSTS}; do find ${SCRIPT_DIR}/../data/digitalassets.lib.berkeley.edu/ds/${x}/mets -maxdepth 1 -name \*.xml | sort | head -100; done)
# Convert CSV format
${SCRIPT_DIR}/../bin/recon places "${recon_opts[@]}" -a legacy -t mets $files

##########
# MARC XML
##########
# Run through the MARC_INSTS and output a CSV for each to TMP_DIR
for inst in ${MARC_INSTS}
do
  ${SCRIPT_DIR}/../bin/recon places "${recon_opts[@]}" -a ${inst} -t marc ${SCRIPT_DIR}/../data/prototype-data/${inst}/*.xml
done

##########
# FLP TEI
##########
# Run through the TEI_INSTS and output a CSV for each to TMP_DIR
for inst in ${TEI_INSTS}
do
  ${SCRIPT_DIR}/../bin/recon places "${recon_opts[@]}" -a ${inst} -t tei ${SCRIPT_DIR}/../data/prototype-data/${inst}/*.xml
done

#######################
# Combine in single CSV
#######################
# list of all of the CSVs: legacy.csv penn.csv [...]
CSVS=$(for x in legacy ${MARC_INSTS} ${TEI_INSTS}; do echo "${TMP_DIR}/places-${x}.csv"; done)

ruby ${SCRIPT_DIR}/csv_cat.rb --sort --uniq -o ${TMP_DIR}/places-combined.csv $CSVS
