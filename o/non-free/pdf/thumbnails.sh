#!/bin/bash

for PDF in `ls *.pdf`
 do  
    convert -resize 348 \
            -border 1x1 -bordercolor black \
	    $PDF \
	    ${PDF%%.*}.gif
 done


exit 0;
