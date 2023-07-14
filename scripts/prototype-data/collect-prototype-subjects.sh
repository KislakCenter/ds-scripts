#!/usr/bin/env bash

###############################################################################
#
# Script to pull together in a single CSV data for the DS 2.0 prototype.
#
###############################################################################
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TMP_DIR=${SCRIPT_DIR}/../../tmp
[[ -e ${TMP_DIR} ]] || mkdir -v ${TMP_DIR} # Create TMP_DIR if it doesn't exist

####################
# CONFIGURATION VARS
####################
# These are the folders in data/prototype-data/ containing MARC XML
MARC_INSTS="penn cornell columbia burke oregon princeton hrc"

LEGACY_INSTS="conception csl cuny grolier gts indiana kansas nelsonatkins nyu providence rutgers ucb wellesley"

#################################
# Update the recon files from git
#################################
${SCRIPT_DIR}/../../bin/ds-recon recon-update

# use the same output directory and skip the calls to git
recon_opts=(--directory ${TMP_DIR} --skip-recon-update)

################
# DS legacy METS
################
# the first 100 records for each of the legacy institutions
files=$(for x in ${LEGACY_INSTS}; do find ${SCRIPT_DIR}/../../data/digitalassets.lib.berkeley.edu/ds/${x}/mets -maxdepth 1 -name \*.xml | sort | head -100; done)
# Convert CSV format
${SCRIPT_DIR}/../../bin/ds-recon subjects "${recon_opts[@]}" -a legacy -t mets $files


##########
# MARC XML
##########
# Run through the MARC_INSTS and output a CSV for each to TMP_DIR
for inst in ${MARC_INSTS}
do
  ${SCRIPT_DIR}/../../bin/ds-recon subjects "${recon_opts[@]}" -a ${inst} -t marc ${SCRIPT_DIR}/../../data/prototype-data/${inst}/*.xml
done

#######################
# Combine in single CSV
#######################
CSVS=$(for x in legacy ${MARC_INSTS}; do echo "${TMP_DIR}/subjects-${x}.csv"; done)

ruby ${SCRIPT_DIR}/csv_cat.rb --sort --uniq -o ${TMP_DIR}/subjects-combined.csv $CSVS
