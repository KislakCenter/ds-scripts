# Data for the prototype test

We agreed we have the following legacy data would include 50 records from the
following

Legacy DS (50 each institution)
Penn
Columbia
FLP
Wellesley
Cornell
Harvard
Beinecke
Princeton
Huntington

We also pull data for a number of institutions for which we have MARC XML.

To create the output, run: `collect-prototype-data.sh`. It will output
`combined-ds.csv` to a `tmp` dir in the root of this project.

```shell
sh scripts/collect-prototype-data.sh
```

# Where the data comes from

NOTE: DO NOT RUN THE CODE BELOW

The following documents how the data was assembled for the prototype.

## First fifty records from the DS dependent institutions, based on legacy METS:

```shell
## No need to run this. This is handled by the
institutions="conception csl cuny grolier gts indiana kansas nelsonatkins nyu providence rutgers ucb wellesley"

# the first 50 records for each of the above institutions; 450 files total
files=$(for x in ${institutions}; do find data/digitalassets.lib.berkeley.edu/ds/${x}/mets -name \*.xml | sort | head -50; done)
```

## Fifty MSS from UPenn from OPenn

These URLs were used to extract bibids for Penn manuscripts on OPenn. These were
then used pull the data MARC XML from Marmite. Twenty-five are from BiblioPhilly
and twenty-five are from Manuscripts of the Muslim World.

```shell
https://openn.library.upenn.edu/Data/0001/ljs101/data/ljs101_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs108/data/ljs108_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs110/data/ljs110_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs115/data/ljs115_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs119/data/ljs119_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs124/data/ljs124_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs16/data/ljs16_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs172/data/ljs172_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs174/data/ljs174_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs177/data/ljs177_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs184/data/ljs184_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs188/data/ljs188_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs189/data/ljs189_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs191/data/ljs191_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs194/data/ljs194_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs195/data/ljs195_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs198/data/ljs198_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs19/data/ljs19_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs204/data/ljs204_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs20/data/ljs20_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs211/data/ljs211_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs212/data/ljs212_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs215/data/ljs215_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs216/data/ljs216_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs220/data/ljs220_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs422/data/ljs422_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex23/data/mscodex23_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1743/data/mscodex1743_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1896/data/mscodex1896_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1898/data/mscodex1898_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1900/data/mscodex1900_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1912/data/mscodex1912_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1913/data/mscodex1913_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1951/data/mscodex1951_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1963/data/mscodex1963_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1962/data/mscodex1962_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1964/data/mscodex1964_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex24/data/mscodex24_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex42/data/mscodex42_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex44/data/mscodex44_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1892/data/mscodex1892_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1893/data/mscodex1893_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1894/data/mscodex1894_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1895/data/mscodex1895_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1899/data/mscodex1899_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1901/data/mscodex1901_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1902/data/mscodex1902_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1903/data/mscodex1903_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1904/data/mscodex1904_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1907/data/mscodex1907_TEI.xml
```

```ruby
# get_bibids.rb
#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'

ARGF.each do |url|
  xml = URI.open(url.strip) { |f| Nokogiri::XML f }
  ns = { 't' => 'http://www.tei-c.org/ns/1.0' }
  puts xml.xpath('//t:altIdentifier[@type="bibid"]/t:idno', ns).text.strip
end
```

The bibids are:

```text
9951865503503681
9957602663503681
9949945603503681
9949879143503681
9949967773503681
9949349953503681
9949282643503681
9958778333503681
9950293063503681
9958279783503681
9958452103503681
9950289983503681
9949222153503681
9950320043503681
9948120243503681
9958589513503681
9953161073503681
9949237593503681
9953161123503681
9949240153503681
9949956063503681
9957604903503681
9950345623503681
9948124823503681
9958854883503681
9954448733503681
9914691813503681
9962793893503681
9977459941003681
9977459940903681
9977459940303681
9977459936903681
9977459936703681
9977459941103681
9962565163503681
9962793853503681
9962793863503681
9914691823503681
9914696413503681
9914696433503681
9969738033503681
9969738073503681
9977325732203681
9977325732103681
9977459940803681
9977406952303681
9977406952203681
9977406952003681
9977406951903681
9977459940203681
```

```shell
for x in `cat bibids.txt `
do
  curl -o "${x}.xml" "http://mdproc.library.upenn.edu:9292/records/${x}/show?format=marc21"
done
```

# MS records from Columbia (MARC XML)

The first 50 records from OPenn for Columbia's special collections and all the
records from Burke Theologiical. All of these MSS are from the Mulsim World
project.

### Columbia MARC on OPenn

```text
https://openn.library.upenn.edu/Data/0032/ms_or_015/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_019/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_024/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_025/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_032/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_044/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_046/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_016/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_021/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_030/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_033/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_036/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_037/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_038/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_039/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_041/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_043/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_047/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_048/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_052/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_054/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_058/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_060/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_049/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_064/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_066/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_072/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_069/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_083/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_091/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_094/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_095/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_096/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_098/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_083a/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_099/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_100/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_101/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_103/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_102/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_104/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_105/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_106/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_107/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_108/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_109/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_110/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_111/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_112/data/marc.xml
https://openn.library.upenn.edu/Data/0032/ms_or_113/data/marc.xml
```

```shell
# for each URL download the file with prefixed with the shelfmark folder
# e.g., ms_or_015-marc.xml
for x in $urls; do mark=$(awk -F/ '{ print $6 }' <<< $x); curl -o ${mark}-marc.xml $x; done
```
Files have been downloaded to `data/prototype-data/columbia`.

### Burke MARC on OPenn

```text
https://openn.library.upenn.edu/Data/0033/uts_ms_001_arabic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_010_arabic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_005_arabic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_002_arabic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_009_arabic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_006_arabic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_001_turkic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_002_turkic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_003_turkic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_011_arabic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_023_arabic/data/marc.xml
https://openn.library.upenn.edu/Data/0033/uts_ms_024_arabic/data/marc.xml
```

```shell
# for each URL download the file with prefixed with the shelfmark folder
# e.g., ms_or_015-marc.xml
for x in $urls; do mark=$(awk -F/ '{ print $6 }' <<< $x); curl -o ${mark}-marc.xml $x; done
```
Files have been downloaded to `data/prototype-data/burke`.
