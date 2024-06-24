#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

csv_dir=${SCRIPT_DIR}/../tmp/test/csv
mets_dir=${SCRIPT_DIR}/../tmp/test/mets
marc_dir=${SCRIPT_DIR}/../tmp/test/marc
tei_dir=${SCRIPT_DIR}/../tmp/test/tei

for x in ${csv_dir} ${mets_dir} ${marc_dir} ${tei_dir}
do
  [[ -e ${x} ]] || mkdir -vp ${x}
  rm -vf ${x}/*
done

recon_args="--source-type ds-csv      -o ${csv_dir}   ${SCRIPT_DIR}/../../ds-member-data/test/20240604/csv-test/20240604-rutgers-hebrew-csv.csv
--source-type ds-mets-xml -o ${mets_dir}  ${SCRIPT_DIR}/../../ds-member-data/test/20240604/mets-test/*.xml
--source-type marc-xml    -o ${marc_dir}  ${SCRIPT_DIR}/../../ds-member-data/test/20240604/marc-test/*.xml
--source-type tei-xml     -o ${tei_dir}   ${SCRIPT_DIR}/../../ds-member-data/test/20240604/tei-test/*.xml"

echo "${recon_args}" | while read -r args
do
  ${SCRIPT_DIR}/../bin/ds-recon write-all ${args}
done

convert_args="-o ${tei_dir}/import.csv ../ds-member-data/test/20240604/tei-test/20220604-tei-test-set-flp-manifest.csv
-o ${mets_dir}/import.csv ../ds-member-data/test/20240604/mets-test/20240604-mets-test-set-missouri-manifest.csv
-o ${csv_dir}/import.csv ../ds-member-data/test/20240604/csv-test/20240604-csv-test-set-rutgers-manifest.csv
-o ${marc_dir}/import.csv ../ds-member-data/test/20240604/marc-test/20240604-marc-test-set-kansas-manifest.csv"

echo "${convert_args}" | while read -r args
do
  ${SCRIPT_DIR}/../bin/ds-convert convert $args
done
