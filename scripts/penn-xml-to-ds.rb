#!/usr/bin/env ruby

######
# Script to convert UPenn Marc XML to DS 2.0 format.
#
# Input should be an MMS ID.
#
# The initial test set will use these IDs:
#
#   9947675343503681
#   9952666523503681
#   9959647633503681
#   9950569233503681
#   9976106713503681
#   9965025663503681

# DS ID
# Date Added
# Date Last Updated
# Holding Institution
# Holding Institution ID number (shelfmark, call number, etc)
# (Perma)Link to Holding Institution's record
# Production Place As Recorded
# Production Place
# Production Date As Recorded
# Production Date
# Century
# Dated
# Uniform Title (240)
# Title As Recorded (245; Title Statement)
# Work As Recorded
# Work
# Genre As Recorded
# Genre
# Subject As Recorded
# Subject
# Author As Recorded
# Author
# Artist As Recorded
# Artist
# Scribe As Recorded
# Scribe
# Language As Recorded
# Language
# Illuminated initials?
# Miniatures?
# Former Owner As Recorded
# Former owner
# Former ID number
# Material
# Physical Description
# Acknowledgements
# Binding
# Folios
# Dimensions
# Decoration

require 'nokogiri'
require 'csv'




