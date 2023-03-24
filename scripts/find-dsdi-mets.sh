#!/usr/bin/env bash

##
# Script to find METS for all DS-dependent institutions.

FIND_DIRS=$(echo data/digitalassets.lib.berkeley.edu/ds/{rome,conception,csl,cuny,grolier,gts,indiana,nelsonatkins,nyu,providence,rutgers,smith}/mets)

find ${FIND_DIRS} -maxdepth 1 -type f -name "*.xml"