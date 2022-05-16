#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

for x in "${SCRIPT_DIR}"/collect-prototype*.sh
do
  echo "=== running ${x} ==="
  sh "${x}"
done

dstamp=$(date +%Y%m%d)
dir=tmp/ds-data-${dstamp}

[[ ! -d ${dir} ]] && mkdir ${dir}
[[ ! -d ${dir}/archive ]] && mkdir ${dir}/archive
mv -v tmp/*-combined.csv ${dir}/
mv -v tmp/*.csv ${dir}/archive

