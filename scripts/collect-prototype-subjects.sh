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
# These are the folders in data/prototype-data/ containing MARC XML
MARC_INSTS="penn cornell columbia burke oregon princeton"

##########
# MARC XML
##########
# Run through the MARC_INSTS and output a CSV for each to TMP_DIR
for inst in ${MARC_INSTS}
do
  ${SCRIPT_DIR}/../bin/recon subjects -o ${TMP_DIR} -a ${inst} -t marc ${SCRIPT_DIR}/../data/prototype-data/${inst}/*.xml
done

#######################
# Combine in single CSV
#######################
CSVS=$(for x in ${MARC_INSTS}; do echo "${TMP_DIR}/subjects-${x}.csv"; done)

ruby ${SCRIPT_DIR}/csv_cat.rb -o ${TMP_DIR}/subjects-combined.csv $CSVS
