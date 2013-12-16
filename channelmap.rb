#!/usr/bin/env ruby

## combines rptrraw.txt and channels.csv (csv export from chirp)
## to produce the google earth map of just the channels on your radio
## note that frequencies are shared, so one channel will work in several places

require 'csv'

src = "rptrraw.txt"
channels = "channels.csv"
puts '<?xml version="1.0" encoding="UTF-8"?>'
puts '<kml xmlns="http://www.opengis.net/kml/2.2">'
puts ' <Document>'
puts '  <name>Map of your radio\'s channels</name>'
puts '  <open>1</open>'
puts '  <description>Mapping of recognized repeaters</description>'
puts '  <LookAt><longitude>-111.3644</longitude><latitude>39.6181</latitude><altitude>2500</altitude><heading>0</heading><tilt>0</tilt><range>900000</range></LookAt>'
repeaters = {}
CSV.foreach(src, :encoding => 'windows-1251:utf-8', :headers => true) do |row|
  next if row['LATITUDE'].to_f == 0
  next if row['LONGITUDE'].to_f == 0
  next unless row['Active'] == 'Y'
  next unless row['OPEN'] == 'Y'
  next if row['CLOSED'] == 'Y'
  next if row['EXPERIMENTAL'] == 'Y'
  (repeaters["#{row['OUTPUT'].to_f}:#{row['INPUT'].to_f}:#{row['CTCSS_IN']}#{row['DCS_CODE'].to_s.strip}"] ||= []) << row
end
hitlist = {}
CSV.foreach(channels, :headers => true) do |row|
  output = row['Frequency'].to_f
  input = (output * 1000.0 + (row['Duplex'].to_s + row['Offset'].to_s).to_f * 1000.0)/ 1000.0
  tone = if row['Tone'] == 'Tone'
    row['rToneFreq']
  elsif row['Tone'] == 'DTCS'
    "D#{row['DtcsCode']}N"
  end
  key = "#{output}:#{input}:#{tone}"
  hits = repeaters[key]
  if hits
    (hitlist[key] ||= []) << "#{row['Location']}:#{row['Name']}"
    #puts "##{row['Location']} #{row['Name']}: #{hits.map{|hit| hit['CALLSIGN']}.join(' ')}"
    hits.each do |hit|
      puts "   <Placemark>"
      puts "    <name>#{row['Location']}#{'x' if hit['LINKED'] == 'Y'}</name>"
      puts "    <description>#{row['Name']} #{hit['CALLSIGN']} #{hit['Site Name']} Notes=#{hit['NOTES']} Link=#{hit['LINK_FREQ']} #{hit['INTERNET_LINK']} #{hit['OUTPUT']}(#{[hit['INPUT'],hit['CTCSS_IN'],hit['DCS_CODE']].compact.join('@')})</description>"
      puts "    <Point><coordinates>#{hit['LONGITUDE']},#{hit['LATITUDE']},0</coordinates></Point>"
      puts '   </Placemark>'
    end
  else
    $stderr.puts "##{row['Location']} #{row['Name']}: no result on #{key}"
    #puts row.inspect
  end
end
#puts repeaters.keys.sort.join(' ')
puts ' </Document>'
puts '</kml>'

$stderr.puts "\nDouble-covered repeaters in your list:"
hitlist.keys.select{|key| hitlist[key].count > 1}.each do |key|
  $stderr.puts hitlist[key].join(', ')
end

$stderr.puts "\nRepeaters you have not covered:"
keys = (repeaters.keys - hitlist.keys).select{|key| ["144","440"].include? repeaters[key].first["BAND"]}
keys.sort!{|k1,k2| repeaters[k2].count <=> repeaters[k1].count}
keys.each do |key|
  cluster = repeaters[key]
  next unless ["144","440"].include? cluster.first["BAND"]
  $stderr.puts key + " " + cluster.map{|repeater| "#{repeater['LOCATION']}#{" wide" if repeater['WIDE_AREA'] == 'Y'}#{" linked" if repeater['LINKED'] == 'Y'}"}.join(', ')
end


# row sample
# {"BAND":"144" "OUTPUT":"146.7600" "INPUT":"146.1600" "STATE":"UT" "LOCATION":"Provo" "CALLSIGN":"W7SP" "SPONSOR":"UARC" "SOURCE":"UVHFS" "AREA":"Wasatch Front"
# "COORDINATED":"Y" "OPEN":"Y" "CLOSED":"N" "BILINGUAL":nil "EXPERIMENTAL":"N" "LITZ":"N" "TONE":"N" "CTCSS_IN":nil "CTCSS_OUT":nil "DCS":"N" "DCS_CODE":nil "DTMF":"N"
# "REMOTE_BASE":"N" "SNP":"N" "AUTOPATCH":"Y" "PATCH_SEQ":nil "CLOSED_PATCH":"Y" "EMERG_POWER":"Y" "EMERG_SUN":"N" "EMERG_WIND":"N" "LINKED":"N" "LINK_FREQ":nil
# "PORTABLE":"N" "RACES":"N" "ARES":"N" "WIDE_AREA":"Y" "LAW":"N" "LAW_DTMF":nil "WEATHER":"N" "WEATHER_DTMF":nil "LATITUDE":"40.2822" "LONGITUDE":"-111.9361"
# "INTERNET":"Y" "INTERNET_LINK":"IRLP 3352" "NOTES":"O E Ca X" "UPDATE":"8/30/1991" "CORD_DATE":"1/1/1978" "USE":"RO" "LATITUDE_DDMMSS":"401656"
# "LONGITUDE_DDDMMSS":"1115610" "AMSL_FEET":"7635" "TX_POWER":nil "ANT_INFO":nil "ERP":"100" "PUB_CODE":"Y" "Active":"Y" "Site Name":"Lake Mtn State site north end"
# "Coverage Area":"UTCO/SLC/CDRVLY" "Footnotes":nil "Contact Email":nil "Repeater Web Page":"http://www.utaharc.org/rptr/uarcrpt.html" "MapSel":"WFU" "Contact Phone":nil
# "Update Source":nil "Coord. Notes":nil "Mailing Address":nil}

# chirp export sample
#<CSV::Row "Location":"1" "Name":"FRS-G-1" "Frequency":"462.562500" "Duplex":nil "Offset":"0.000000" "Tone":nil "rToneFreq":"88.5" "cToneFreq":"88.5" "DtcsCode":"023" "DtcsPolarity":"NN" "Mode":"NFM" "TStep":"5.00" "Skip":nil "Comment":nil "URCALL":nil "RPT1CALL":nil "RPT2CALL":nil nil:nil>
