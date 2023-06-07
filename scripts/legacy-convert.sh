#!/usr/bin/env bash

# Uncomment for noisy logging
#export DS_LOGLEVEL=DEBUG

##
# Batch 1
#
# State of California (csl): 39
# City College of New York (cuny): 1
# Grolier Club (grolier): 18
# Providence Public Library (providence): 5

members1="
csl
cuny
grolier
providence"

##
# Batch 2
#
# American Academy in Rome (rome): 2
# Nelson-Atkins Museum (nelsonatkins): 36
# Smith College (smith): 11
members2="
rome
nelsonatkins
smith"

##
# Batch 3
#
# General Theological Seminary (gts): 24
# Indiana University (indiana): 103
# New York University (nyu): 106
# Rutgers University (rutgers): 60
members3="
gts
indiana
nyu
rutgers"

this_dir=$(dirname $0)
tmp_dir=${this_dir}/../tmp

ds_dir=${this_dir}/../data/digitalassets.lib.berkeley.edu/ds
dest_base=${this_dir}/../tmp/mets-recon-$(date +%Y-%m-%d)

[[ -e ${dest_base} ]] || mkdir "${dest_base}"

for member in ${members1}
do
  echo
  echo " ==== Creating import CSV for ${member} ===="
  echo
  dest_dir=${dest_base}/${member}
  [[ -e ${dest_dir} ]] || mkdir "${dest_dir}"
  ${this_dir}/../bin/ds-convert mets -o ${tmp_dir}/ds-import-${member}.csv ${ds_dir}/${member}/mets/*.xml
done

