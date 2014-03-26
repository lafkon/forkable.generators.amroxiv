#!/bin/bash

for SVG in `ls *.svg`
 do
   
   inkscape --export-png=${SVG%%.*}.png \
            --export-width=348 \
            --export-background=FFFFFF \
             $SVG
    convert -border 1x1 -bordercolor black \
	     ${SVG%%.*}.png \
	     ${SVG%%.*}.gif

   rm ${SVG%%.*}.png

 done


exit 0;
