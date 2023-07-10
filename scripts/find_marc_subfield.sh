#!/usr/bin/env bash

# Usage: find_marc_code DATAFIELD_TAG SUBFIELD_CODE FILE[...]
#
# Prints out the field with code on context:
#
# Example: sh ./scripts/scratch_3.sh 245 f $(find data/prototype-data -type f -name \*.xml)
#
# data/prototype-data/cornell/cornell-marc-010.xml:  ><tag ind1='0' ind2='0' tag='245'
# data/prototype-data/cornell/cornell-marc-010.xml-  ><code code='a'
# data/prototype-data/cornell/cornell-marc-010.xml-    >Epistles of St. Paul, with commentary,</code
# data/prototype-data/cornell/cornell-marc-010.xml-    ><code code='f'
# data/prototype-data/cornell/cornell-marc-010.xml-    >[ca. 1100-1135]</code
# --
# data/prototype-data/cornell/cornell-marc-007.xml:  ><tag ind1='0' ind2='0' tag='245'
# data/prototype-data/cornell/cornell-marc-007.xml-  ><code code='a'
# data/prototype-data/cornell/cornell-marc-007.xml-    >Sermones,</code
# data/prototype-data/cornell/cornell-marc-007.xml-    ><code code='f'
# data/prototype-data/cornell/cornell-marc-007.xml-    >[13--]</code
# ...
#

usage() {
  echo "Usage: find_marc_code.sh DATAFIELD_TAG SUBFIELD_CODE FILE[...]"
}

tag=$1
shift
code=$1
shift
files=$@

if ! egrep -q "^\d{3}$" <<< "${tag}"
then
  usage
  echo ""
  echo "Not a 3-digit datafiled tag: '${tag}'"
  exit 1
fi

if ! egrep -q "^[a-z]$" <<< "${code}"
then
  usage
  echo ""
  echo "Not a subfield code: '${code}'"
  exit 1
fi

if [[ -z "$files" ]]
then
  usage
  echo ""
  echo "No files provided"
  exit 1
fi

egrep -A 4 "tag=.${tag}." ${files} | egrep "code=.${code}." | \
while read line
do
 file=$(awk '{ print $1}' | sed 's/-$//')
 egrep -A 4 "tag=.${tag}." ${file}
done

if [[ $? -ne 0 ]]
then
  usage
  exit 1
fi