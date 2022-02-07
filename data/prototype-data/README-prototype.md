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
https://openn.library.upenn.edu/Data/0001/ljs223/data/ljs223_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs224/data/ljs224_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs225/data/ljs225_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs226/data/ljs226_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs229/data/ljs229_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs231/data/ljs231_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs232/data/ljs232_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs234/data/ljs234_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs235/data/ljs235_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs236/data/ljs236_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs237/data/ljs237_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs238/data/ljs238_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs239/data/ljs239_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs23/data/ljs23_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs242/data/ljs242_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs24/data/ljs24_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs252/data/ljs252_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs254/data/ljs254_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs255/data/ljs255_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs25/data/ljs25_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs264/data/ljs264_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs265/data/ljs265_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs266/data/ljs266_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs267/data/ljs267_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs268/data/ljs268_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs26/data/ljs26_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs271/data/ljs271_TEI.xml
https://openn.library.upenn.edu/Data/0001/ljs278/data/ljs278_TEI.xml
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
https://openn.library.upenn.edu/Data/0002/mscodex1909/data/mscodex1909_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1910/data/mscodex1910_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1914/data/mscodex1914_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1915/data/mscodex1915_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1916/data/mscodex1916_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1917/data/mscodex1917_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1918/data/mscodex1918_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1952/data/mscodex1952_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1958/data/mscodex1958_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1959/data/mscodex1959_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1961/data/mscodex1961_TEI.xml
https://openn.library.upenn.edu/Data/0002/msroll1965/data/msroll1965_TEI.xml
https://openn.library.upenn.edu/Data/0002/miscmss_box24_f3/data/miscmss_box24_f3_TEI.xml
https://openn.library.upenn.edu/Data/0002/miscmss_box24_f4/data/miscmss_box24_f4_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex43/data/mscodex43_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex40/data/mscodex40_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1911/data/mscodex1911_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex1897/data/mscodex1897_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex41/data/mscodex41_TEI.xml
https://openn.library.upenn.edu/Data/0002/msroll1906/data/msroll1906_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex25/data/mscodex25_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex28/data/mscodex28_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex21_v1/data/mscodex21_v1_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex45_v1/data/mscodex45_v1_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex45_v2/data/mscodex45_v2_TEI.xml
https://openn.library.upenn.edu/Data/0002/msindic6/data/msindic6_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex21_v2/data/mscodex21_v2_TEI.xml
https://openn.library.upenn.edu/Data/0002/mscodex21_v3/data/mscodex21_v3_TEI.xml
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
9948175023503681
9959387343503681
9948179063503681
9950511113503681
9959415183503681
9949875283503681
9948181893503681
9959419423503681
9950569233503681
9958895573503681
9947699533503681
9949939943503681
9948558353503681
9947469813503681
9954084983503681
9952666523503681
9947594443503681
9948588323503681
9959171953503681
9946458153503681
9957607433503681
9947675343503681
9949525113503681
9948617063503681
9950583033503681
9946463483503681
9950003033503681
9949183233503681
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
9977406946003681
9977424453803681
9977406951603681
9977406951403681
9977406946103681
9977406951203681
9977406951103681
9977459940003681
9970745763503681
9962496313503681
9962793903503681
9962793913503681
9977459937103681
9977459937003681
9914696423503681
9914696393503681
9977508749303681
9977406953003681
9914696403503681
9977508749403681
9914691833503681
9914691863503681
9914691793503681
9972460113503681
9914691793503681
9914691793503681
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

### FLP TEI on OPenn

To get the TEI paths, I took the CSV from OPenn (https://openn.library.upenn.edu/Data/0023_contents.csv);
sorted the path column and copied a number of paths to a `dirs` variable.
Because splitting a string by whitespace in ZSH always confuses me, here's how
to iterate over `$dirs` in ZSH.

```shell
for x in $(echo $dirs)
do 
  folder=$(awk -F/ '{ print $2 }' <<< $x)
  echo "https://openn.library.upenn.edu/Data/${x}/data/${folder}_TEI.xml"
done
```

```text
https://openn.library.upenn.edu/Data/0023/horace_ms_1a/data/horace_ms_1a_TEI.xml
https://openn.library.upenn.edu/Data/0023/horace_ms_1b/data/horace_ms_1b_TEI.xml
https://openn.library.upenn.edu/Data/0023/horace_ms_2/data/horace_ms_2_TEI.xml
https://openn.library.upenn.edu/Data/0023/lc_14_10/data/lc_14_10_TEI.xml
https://openn.library.upenn.edu/Data/0023/lc_14_12/data/lc_14_12_TEI.xml
https://openn.library.upenn.edu/Data/0023/lc_14_13/data/lc_14_13_TEI.xml
https://openn.library.upenn.edu/Data/0023/lc_14_14/data/lc_14_14_TEI.xml
https://openn.library.upenn.edu/Data/0023/lc_14_19/data/lc_14_19_TEI.xml
https://openn.library.upenn.edu/Data/0023/lc_14_20_5/data/lc_14_20_5_TEI.xml
https://openn.library.upenn.edu/Data/0023/lc_14_21/data/lc_14_21_TEI.xml
https://openn.library.upenn.edu/Data/0023/lc_14_23/data/lc_14_23_TEI.xml
https://openn.library.upenn.edu/Data/0023/lc_14_28/data/lc_14_28_TEI.xml
https://openn.library.upenn.edu/Data/0023/lc_14_9_5/data/lc_14_9_5_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_add_001/data/lewis_add_001_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_add_002/data/lewis_add_002_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_add_003/data/lewis_add_003_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_add_004/data/lewis_add_004_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_c_001/data/lewis_c_001_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_c_002/data/lewis_c_002_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_c_006/data/lewis_c_006_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_c_016/data/lewis_c_016_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_c_017/data/lewis_c_017_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_c_018/data/lewis_c_018_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_c_025/data/lewis_c_025_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_c_026/data/lewis_c_026_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_c_027/data/lewis_c_027_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_001/data/lewis_e_001_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_002/data/lewis_e_002_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_003/data/lewis_e_003_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_004/data/lewis_e_004_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_005/data/lewis_e_005_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_006/data/lewis_e_006_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_007/data/lewis_e_007_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_008/data/lewis_e_008_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_009/data/lewis_e_009_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_010/data/lewis_e_010_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_011/data/lewis_e_011_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_012/data/lewis_e_012_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_014/data/lewis_e_014_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_015/data/lewis_e_015_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_016/data/lewis_e_016_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_017/data/lewis_e_017_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_018/data/lewis_e_018_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_019/data/lewis_e_019_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_020/data/lewis_e_020_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_021/data/lewis_e_021_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_022/data/lewis_e_022_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_023/data/lewis_e_023_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_025/data/lewis_e_025_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_026/data/lewis_e_026_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_027/data/lewis_e_027_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_028/data/lewis_e_028_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_029/data/lewis_e_029_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_030/data/lewis_e_030_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_031/data/lewis_e_031_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_032/data/lewis_e_032_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_033/data/lewis_e_033_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_034/data/lewis_e_034_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_035/data/lewis_e_035_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_036/data/lewis_e_036_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_037/data/lewis_e_037_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_038/data/lewis_e_038_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_039/data/lewis_e_039_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_040/data/lewis_e_040_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_042/data/lewis_e_042_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_043/data/lewis_e_043_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_044/data/lewis_e_044_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_045/data/lewis_e_045_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_046/data/lewis_e_046_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_047/data/lewis_e_047_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_048/data/lewis_e_048_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_049/data/lewis_e_049_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_050/data/lewis_e_050_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_051/data/lewis_e_051_TEI.xml
https://openn.library.upenn.edu/Data/0023/lewis_e_052/data/lewis_e_052_TEI.xml
```

```shell
# for each URL download the file
# e.g., lewis_e_035_TEI.xml
for x in $urls; do curl -O $x; done
```

```shell
# ZSH version
for x in $(echo $urls); do curl -O $x; done
```

Files have been downloaded to `data/prototype/flp`
