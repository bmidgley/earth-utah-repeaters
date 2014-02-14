earth-utah-repeaters
====================

View Utah's repeaters in Google Earth

Uses the list available from http://utahvhfs.org/rptr.html

To use it, click https://rawgithub.com/bmidgley/earth-utah-repeaters/master/repeaters.kml
(You may have to choose file->save and double-click this file to see it in google earth.)

You can click the link above from a mobile device to launch it in google earth mobile.

repeaterbook.com has a similar function for its national data.

I wrote a separate program to plot my radio's channel numbers on a map. If your chirp
export is in channels.csv, run channelmap.rb and it will write them to channels.kml.

This program also writes out additional information about your repeaters; repeaters
it did not recognize, repeater frequency and code that appear more than once in your
list, and repeaters that are not in your list, showing first those that are the most
common settings that will work in multiple places. I snapshot a couple of the google
earth views of this output that I can refer to offline if I need to on my phone.

The channelmap function really should be built into chirp. Imagine File->Export->KML
that would write the current list to KML. I asked the repeaterbook folks if they
have an API to allow that function to work properly but no response yet.

An example channelmap: https://rawgithub.com/bmidgley/earth-utah-repeaters/master/channels.kml

BSD license
