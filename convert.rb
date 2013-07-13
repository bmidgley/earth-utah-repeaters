#!/usr/bin/env ruby
require 'csv'

src = "rptrraw.txt"
#system "rm #{src}; wget 'http://www.ussc.com/~uvhfs/#{src}'"
puts '<?xml version="1.0" encoding="UTF-8"?>'
puts '<kml xmlns="http://www.opengis.net/kml/2.2">'
puts ' <Document>'
puts '  <name>Utah Repeaters</name>'
puts '  <open>1</open>'
puts '  <description>Utah Repeaters from UVHFS</description>'
puts '  <LookAt><longitude>-111.3644</longitude><latitude>39.6181</latitude><altitude>2500</altitude><heading>0</heading><tilt>0</tilt><range>900000</range></LookAt>'
bands = {}
CSV.foreach(src, :encoding => 'windows-1251:utf-8', :headers => true) do |row|
  next if row['LATITUDE'].to_f == 0
  next if row['LONGITUDE'].to_f == 0
  next unless row['Active'] == 'Y'
  next unless row['OPEN'] == 'Y'
  next if row['CLOSED'] == 'Y'
  next if row['EXPERIMENTAL'] == 'Y'
  (bands[row['BAND']] ||= []) << row
end
bands.each_pair do |k,v|
  puts "  <Folder id=\"#{k}\">"
  puts "   <name>#{k} Mhz</name>"
  v.each do |row|
    puts "   <Placemark>"
    puts "    <name>#{row['CALLSIGN']} #{row['Site Name']}</name>"
    puts "    <description>#{row['OUTPUT']}(#{[row['INPUT'],row['CTCSS_IN'],row['DCS_CODE']].compact.join('@')})</description>"
    puts "    <Point><coordinates>#{row['LONGITUDE']},#{row['LATITUDE']},0</coordinates></Point>"
    puts '   </Placemark>'
  end
  puts "  </Folder>"
end
puts ' </Document>'
puts '</kml>'

# row sample
# {"BAND":"144" "OUTPUT":"146.7600" "INPUT":"146.1600" "STATE":"UT" "LOCATION":"Provo" "CALLSIGN":"W7SP" "SPONSOR":"UARC" "SOURCE":"UVHFS" "AREA":"Wasatch Front"
# "COORDINATED":"Y" "OPEN":"Y" "CLOSED":"N" "BILINGUAL":nil "EXPERIMENTAL":"N" "LITZ":"N" "TONE":"N" "CTCSS_IN":nil "CTCSS_OUT":nil "DCS":"N" "DCS_CODE":nil "DTMF":"N"
# "REMOTE_BASE":"N" "SNP":"N" "AUTOPATCH":"Y" "PATCH_SEQ":nil "CLOSED_PATCH":"Y" "EMERG_POWER":"Y" "EMERG_SUN":"N" "EMERG_WIND":"N" "LINKED":"N" "LINK_FREQ":nil
# "PORTABLE":"N" "RACES":"N" "ARES":"N" "WIDE_AREA":"Y" "LAW":"N" "LAW_DTMF":nil "WEATHER":"N" "WEATHER_DTMF":nil "LATITUDE":"40.2822" "LONGITUDE":"-111.9361"
# "INTERNET":"Y" "INTERNET_LINK":"IRLP 3352" "NOTES":"O E Ca X" "UPDATE":"8/30/1991" "CORD_DATE":"1/1/1978" "USE":"RO" "LATITUDE_DDMMSS":"401656"
# "LONGITUDE_DDDMMSS":"1115610" "AMSL_FEET":"7635" "TX_POWER":nil "ANT_INFO":nil "ERP":"100" "PUB_CODE":"Y" "Active":"Y" "Site Name":"Lake Mtn State site north end"
# "Coverage Area":"UTCO/SLC/CDRVLY" "Footnotes":nil "Contact Email":nil "Repeater Web Page":"http://www.utaharc.org/rptr/uarcrpt.html" "MapSel":"WFU" "Contact Phone":nil
# "Update Source":nil "Coord. Notes":nil "Mailing Address":nil}
