#!/usr/bin/env bash

# Uncomment for noisy logging
#export DS_LOGLEVEL=DEBUG

members="rome
conception
csl
cuny
grolier
gts
indiana
nelsonatkins
nyu
providence
rutgers
smith"

this_dir=$(dirname $0)

ds_dir=${this_dir}/../data/digitalassets.lib.berkeley.edu/ds
dest_base=${this_dir}/../tmp/mets-recon-$(date +%Y-%m-%d)

[[ -e ${dest_base} ]] || mkdir "${dest_base}"

for member in ${members}
do
  echo
  echo " ==== Creating recon CSVs for ${member} ===="
  echo
  dest_dir=${dest_base}/${member}
  [[ -e ${dest_dir} ]] || mkdir "${dest_dir}"
  ./scripts/gen-recon-csvs.rb -a ${member} -t mets -o "${dest_dir}" ${ds_dir}/${member}/mets/*.xml
done

