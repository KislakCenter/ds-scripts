#!/usr/bin/env bash

###############################################################################
#
# Script to pull recon values for names, places, materials, and languages for
# all legacy DS METS files.
#
###############################################################################
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#TMP_DIR=${SCRIPT_DIR}/../../tmp
#[[ -e ${TMP_DIR} ]] || mkdir -v ${TMP_DIR} # Create TMP_DIR if it doesn't exist
#OUT_DIR=${TMP_DIR}/mets_recon
#[[ -e ${OUT_DIR} ]] || mkdir ${OUT_DIR}

##############
# Pre-run test
##############
if [[ -e ${SCRIPT_DIR}/../../data/digitalassets.lib.berkeley.edu/ds ]]; then
  : # do nothing; we the METS files are available
else
  echo "ERROR: METS folders not found: '${SCRIPT_DIR}/../../data/digitalassets.lib.berkeley.edu/ds'" >&2
  echo "Please: unzip ${SCRIPT_DIR}/../../data/digitalassets-lib-berkeley-edu.tgz to ${SCRIPT_DIR}/../../data" >&2
  echo "Run: " >&2
  echo "    tar xf ${SCRIPT_DIR}/../../data/digitalassets-lib-berkeley-edu.tgz --directory ${SCRIPT_DIR}/../../data" >&2
  exit 1
fi

LEGACY_INSTS="beinecke
               chicago
               columbia
               conception
               csl
               cuny
               fordham
               freelib
               grolier
               gts
               harvard
               huntington
               indiana
               jhopkins
               jtsa
               kansas
               missouri
               mokna
               nelsonatkins
               notredame
               nyam
               nypl
               nyu
               oberlin
               penn
               pittsburgh
               providence
               rome
               rutgers
               sfu
               slu
               smith
               tufts
               txaustin
               ucb
               ucd
               ucr
               upenn
               uvm
               walters
               wellesley"

# uncomment following line to use a short list for testing
#LEGACY_INSTS="rutgers conception"

paths=$(for x in ${LEGACY_INSTS}; do echo ${SCRIPT_DIR}/../../data/digitalassets.lib.berkeley.edu/ds/${x}/mets ; done )

TMP_DIR=${SCRIPT_DIR}/../../tmp
[[ -e ${TMP_DIR} ]] || mkdir -v ${TMP_DIR} # Create TMP_DIR if it doesn't exist
OUT_DIR=${TMP_DIR}/mets_recon
[[ -e ${OUT_DIR} ]] || mkdir ${OUT_DIR}

recon_opts=(--directory ${OUT_DIR} --skip-recon-update)

${SCRIPT_DIR}/../../bin/ds-recon recon-update

find ${paths} -maxdepth 1 -name \*.xml | ${SCRIPT_DIR}/../../bin/ds-recon names "${recon_opts[@]}" -v -a mets -t mets -
find ${paths} -maxdepth 1 -name \*.xml | ${SCRIPT_DIR}/../../bin/ds-recon places "${recon_opts[@]}" -v -a mets -t mets -
find ${paths} -maxdepth 1 -name \*.xml | ${SCRIPT_DIR}/../../bin/ds-recon languages "${recon_opts[@]}" -v -a mets -t mets -
find ${paths} -maxdepth 1 -name \*.xml | ${SCRIPT_DIR}/../../bin/ds-recon materials "${recon_opts[@]}" -v -a mets -t mets -
