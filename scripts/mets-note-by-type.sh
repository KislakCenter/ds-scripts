#!/usr/bin/env bash

# Script to extract mods:note values by type

THIS_DIR=$(dirname $0)

FIND_DIRS=$(echo data/digitalassets.lib.berkeley.edu/ds/{rome,conception,csl,cuny,grolier,gts,indiana,nelsonatkins,nyu,providence,rutgers,smith})

type="$@"

if [[ -z "${type}" ]]
then
  note_string="<mods:note>"
  else
    note_string="<mods:note type=\"${type}\">"
fi

find ${FIND_DIRS} -maxdepth 2 -type d -name mets | while read -r dir
do
  grep -nF "${note_string}" ${dir}/*.xml
done