#!/bin/bash

#.-------------------------------------------------------------------------.#
#. amroxiv.sh                                                               #
#.                                                                          #
#. Copyright (C) 2014 LAFKON/Christoph Haag                                 #
#.                                                                          #
#. This file is part of the id 'Art meets Radical Openness Festival 2014    #
#.                                                                          #
#. amroxiv.sh is free software: you can redistribute it and/or modify       #
#. it under the terms of the GNU General Public License as published by     #
#. the Free Software Foundation, either version 3 of the License, or        #
#. (at your option) any later version.                                      #
#.                                                                          #
#. do.sh is distributed in the hope that it will be useful,                 #
#. but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#. MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     #
#. See the GNU General Public License for more details.                     #
#.                                                                          #
#.-------------------------------------------------------------------------.#

  TMPDIR=tmp
  OUTPUTDIR=tmp

  SVG=i/free/svg/140302--bOUND-14.svg
  SVG=i/free/svg/amroxiv.svg
  MASTERNAME=`basename $SVG | cut -d "." -f 1`

# --------------------------------------------------------------------------- #
# SEPARATE SVG BODY FOR EASIER PARSING (BUG FOR EMPTY LAYERS SOLVED)
# --------------------------------------------------------------------------- #

      sed 's/ / \n/g' $SVG | \
      sed '/^.$/d' | \
      sed -n '/<\/metadata>/,/<\/svg>/p' | sed '1d;$d' | \
      sed ':a;N;$!ba;s/\n/ /g' | \
      sed 's/<\/g>/\n<\/g>/g' | \
      sed 's/\/>/\n\/>\n/g' | \
      sed 's/\(<g.*inkscape:groupmode="layer"[^"]*"\)/QWERTZUIOP\1/g' | \
      sed ':a;N;$!ba;s/\n/ /g' | \
      sed 's/QWERTZUIOP/\n\n\n\n/g' | \
      sed 's/display:none/display:inline/g' > ${SVG%%.*}.tmp

  SVGHEADER=`tac $SVG | sed -n '/<\/metadata>/,$p' | tac`

# --------------------------------------------------------------------------- #
# WRITE LIST WITH LAYERS
# --------------------------------------------------------------------------- #

  LAYERLIST=layer.list ; if [ -f $LAYERLIST ]; then rm $LAYERLIST ; fi
  TYPESLIST=types.list ; if [ -f $TYPESLIST ]; then rm $TYPESLIST ; fi

  CNT=1
  for LAYER in `cat ${SVG%%.*}.tmp | \
                sed 's/ /ASDFGHJKL/g' | \
                sed '/^.$/d' | \
                grep -v "label=\"XX_"`
   do
       NAME=`echo $LAYER | \
             sed 's/ASDFGHJKL/ /g' | \
             sed 's/\" /\"\n/g' | \
             grep inkscape:label | grep -v XX_ | \
             cut -d "\"" -f 2 | sed 's/[[:space:]]\+//g'`
       echo $NAME >> $LAYERLIST
       CNT=`expr $CNT + 1`
  done

  cat $LAYERLIST | sed '/^$/d' | sort | uniq > $TYPESLIST

# --------------------------------------------------------------------------- #
# GENERATE CODE FOR FOR-LOOP TO EVALUATE COMBINATIONS
#---------------------------------------------------------------------------- #

  KOMBILIST=kombinationen.list ; if [ -f $KOMBILIST ]; then rm $KOMBILIST ; fi

  # RESET (IMPORTANT FOR 'FOR'-LOOP)
  LOOPSTART=""
  VARIABLES=""
  LOOPCLOSE=""  

  CNT=0  
  for BASETYPE in `cat $TYPESLIST | cut -d "-" -f 1 | sort | uniq`
   do
      LOOPSTART=${LOOPSTART}"for V$CNT in \`grep \"${BASETYPE}-\" $TYPESLIST \`; do "
      VARIABLES=${VARIABLES}'$'V${CNT}" "
      LOOPCLOSE=${LOOPCLOSE}"done; "

      CNT=`expr $CNT + 1`;
  done

# --------------------------------------------------------------------------- #
# EXECUTE CODE FOR FOR-LOOP TO EVALUATE COMBINATIONS
# --------------------------------------------------------------------------- #

# echo ${LOOPSTART}" echo $VARIABLES >> $KOMBILIST ;"${LOOPCLOSE}
  eval ${LOOPSTART}" echo $VARIABLES >> $KOMBILIST ;"${LOOPCLOSE}

  echo " "`wc -l $KOMBILIST | cut -d " " -f 1`" possible combinations"

# --------------------------------------------------------------------------- #
# ADD MD5SUM TO EVERY COMBINATION, USED TO SORT AND SELECT (=NOT SO RANDOM)
# --------------------------------------------------------------------------- #

  for KOMBI in `cat $KOMBILIST | sed 's/ /DHSZEJDS/g'`
   do
       KOMBI=`echo $KOMBI | sed 's/DHSZEJDS/ /g'`
       ID=`echo ${KOMBI} | md5sum | cut -c 1-10 | rev`-
       sed -i "s/${KOMBI}/${ID}&/g" $KOMBILIST 
  done


# --------------------------------------------------------------------------- #
# WRITE SVG FILES ACCORDING TO POSSIBLE COMBINATIONS
# --------------------------------------------------------------------------- #

  ONUM=100
  FINALOUTPUTDIR=o/free/svg
  NONFREEDIR=o/non-free/pdf

  SUPPORTER=i/non-free/svg/amroxiv_supporter.svg
  inkscape --export-pdf=${SUPPORTER%%.*}.pdf $SUPPORTER

  for KOMBI in `cat $KOMBILIST | sed 's/ /DHSZEJDS/g' | \
                sort | head -n $ONUM `
   do
      KOMBI=`echo $KOMBI | cut -d "-" -f 2- | sed 's/DHSZEJDS/ /g'`

      NAME=`basename $SVG | cut -d "." -f 1`
      OSVG=$FINALOUTPUTDIR/${NAME}_`echo ${KOMBI} | \
                                    md5sum | cut -c 1-7`.svg

      echo "$SVGHEADER"                                   >  $OSVG

       for LAYERNAME in `echo $KOMBI`
        do
          grep -n "label=\"$LAYERNAME\"" ${SVG%%.*}.tmp   >> ${OSVG%%.*}.tmp
       done

      cat ${OSVG%%.*}.tmp | sort -n | cut -d ":" -f 2-    >> $OSVG
      echo "</svg>"                                       >> $OSVG

      rm ${OSVG%%.*}.tmp

      inkscape --export-pdf=${OSVG%%.*}.pdf $OSVG
      PDF=${NONFREEDIR}/`basename $OSVG`
    # pdftk ${SUPPORTER%%.*}.pdf \
    #       background ${OSVG%%.*}.pdf \
    #       output ${PDF%%.*}.pdf
      pdftk ${OSVG%%.*}.pdf \
            background ${SUPPORTER%%.*}.pdf \
            output ${PDF%%.*}.pdf
      rm ${OSVG%%.*}.pdf ${SUPPORTER%%.*}.pdf

  done

# --------------------------------------------------------------------------- #
# REMOVE TEMP FILES
# --------------------------------------------------------------------------- #
  rm ${SVG%%.*}.tmp $KOMBILIST $LAYERLIST $TYPESLIST






exit 0;


