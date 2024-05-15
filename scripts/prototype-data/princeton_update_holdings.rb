#!/usr/bin/env ruby

##
# The Princeton MARC data comes in three files:
#
# - IslamicGarrettBIB1.xml
# - IslamicGarrettBIB2.xml
# - IslamicGarrettHoldingsandMMSID.xml
#
# We don't know the relationship between BIB1 and BIB2. However, the MMSID file
# contains the mapping from the OPAC ID number to the call numbers.
#
# To add Princeton MSS update the file
# `data/prototype-data/princeton/IslamicGarrettBIB1-trim.xml` with a new
# records and then run the following scripts, pointing to the corresponding
# source file.
#
#   bundle exec ruby scripts/princeton_update_bib2.rb \
#       ~/tmp/Islamic\ MSS\ Metadata/IslamicGarrettBIB2.xml
#
#   bundle exec ruby scripts/princeton_update_holdings.rb \
#       ~/tmp/Islamic\ MSS\ Metadata/IslamicGarrettHoldingsandMMSID.xml
#
require 'nokogiri'

holdings_path = ARGV.shift
abort "Please give the path to the MMSIDs file" if holdings_path.nil?
abort "Can't locate MMSIDs file: #{holdings_path}" unless File.exist? holdings_path

bib1_path     = File.expand_path '../../data/prototype-data/princeton/IslamicGarrettBIB1-trim.xml', __FILE__
bib1_trim     = Nokogiri::XML open(bib1_path), nil, "UTF-8"
output_path   = File.expand_path '../../data/prototype-data/princeton/IslamicGarrettHoldingsandMMSID-trim.xml', __FILE__
holdings      = Nokogiri::XML open holdings_path
holdings.remove_namespaces!

# use nokogiri to extract 001 ID
ids               = bib1_trim.xpath("/collection/record/controlfield[@tag=001]").map(&:text)
query             = ids.map { |id| "./C2/text() = '#{id}'" }.join " or " # all the IDs in a single "or" query
matching_elements = holdings.xpath "//R[#{query}]"

File.open output_path, 'w' do |f|
  f.puts %Q{<RS xmlns="urn:schemas-microsoft-com:xml-analysis:rowset">
    <!-- Alma Analytics output. See schema. C0 is their version of MARC, with $$ as delimiter. Holdings and bibliographic record IDs [MARC 001] in C1 and C2, respectively.-->
	<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saw-sql="urn:saw-sql" targetNamespace="urn:schemas-microsoft-com:xml-analysis:rowset">
		<xsd:complexType name="R">
			<xsd:sequence>
				<xsd:element name="C0" type="xsd:string" minOccurs="0" maxOccurs="1" saw-sql:type="varchar" saw-sql:sqlFormula="&quot;Physical Items&quot;.&quot;Holding Details&quot;.&quot;852 MARC&quot;" saw-sql:displayFormula="&quot;Holding Details&quot;.&quot;852 MARC&quot;" saw-sql:aggregationRule="none" saw-sql:aggregationType="nonAgg" saw-sql:tableHeading="Holding Details" saw-sql:columnHeading="852 MARC" saw-sql:isDoubleColumn="false" saw-sql:columnID="c29a01822bd0d50d7" saw-sql:length="1000" saw-sql:scale="0" saw-sql:precision="1000"/>
				<xsd:element name="C1" type="xsd:string" minOccurs="0" maxOccurs="1" saw-sql:type="varchar" saw-sql:sqlFormula="&quot;Physical Items&quot;.&quot;Holding Details&quot;.&quot;Holding Id&quot;" saw-sql:displayFormula="&quot;Holding Details&quot;.&quot;Holding Id&quot;" saw-sql:aggregationRule="none" saw-sql:aggregationType="nonAgg" saw-sql:tableHeading="Holding Details" saw-sql:columnHeading="Holding Id" saw-sql:isDoubleColumn="false" saw-sql:columnID="c5cde877e30ea41da" saw-sql:length="255" saw-sql:scale="0" saw-sql:precision="255"/>
				<xsd:element name="C2" type="xsd:string" minOccurs="0" maxOccurs="1" saw-sql:type="varchar" saw-sql:sqlFormula="&quot;Physical Items&quot;.&quot;Bibliographic Details&quot;.&quot;MMS Id&quot;" saw-sql:displayFormula="&quot;Bibliographic Details&quot;.&quot;MMS Id&quot;" saw-sql:aggregationRule="none" saw-sql:aggregationType="nonAgg" saw-sql:tableHeading="Bibliographic Details" saw-sql:columnHeading="MMS Id" saw-sql:isDoubleColumn="false" saw-sql:columnID="c8f60c7c45c0c561f" saw-sql:length="255" saw-sql:scale="0" saw-sql:precision="255"/>
			</xsd:sequence>
		</xsd:complexType>
	</xsd:schema>}

  f.puts matching_elements

  f.puts '</RS>'
end

STDERR.puts "Wrote: #{output_path}"
