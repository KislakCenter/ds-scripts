#!/usr/bin/env bash

###############################################################################
#
# Script to pull together in a single CSV data for the DS 2.0 prototype.
#
###############################################################################
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TMP_DIR=${SCRIPT_DIR}/../../tmp
[[ -e ${TMP_DIR} ]] || mkdir -v ${TMP_DIR} # Create TMP_DIR if it doesn't exist

#################################
# Update the recon files from git
#################################
${SCRIPT_DIR}/../../bin/ds-recon recon-update

# use the same output directory and skip the calls to git
recon_opts=(--directory ${TMP_DIR} --skip-recon-update)

####################
# CONFIGURATION VARS
####################
# These are the folders in data/prototype-data/ containing MARC XML
MARC_INSTS="penn cornell columbia burke oregon princeton hrc"

##########
# MARC XML
##########
# Run through the MARC_INSTS and output a CSV for each to TMP_DIR
for inst in ${MARC_INSTS}
do
  ${SCRIPT_DIR}/../../bin/ds-recon genres "${recon_opts[@]}" -a ${inst} -t marc ${SCRIPT_DIR}/../../data/prototype-data/${inst}/*.xml
done

# TEI
TEI_INSTS="flp"
##########
# FLP TEI
##########
# Run through the TEI_INSTS and output a CSV for each to TMP_DIR
for inst in ${TEI_INSTS}
do
  ${SCRIPT_DIR}/../../bin/ds-recon genres "${recon_opts[@]}" -a ${inst} -t tei ${SCRIPT_DIR}/../../data/prototype-data/${inst}/*.xml
done

#######################
# Combine in single CSV
#######################
CSVS=$(for x in ${MARC_INSTS}; do echo "${TMP_DIR}/genres-${x}.csv"; done)

ruby ${SCRIPT_DIR}/csv_cat.rb --sort --uniq -o ${TMP_DIR}/genres-combined.csv $CSVS