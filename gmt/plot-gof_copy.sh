
clear

# Set GMT constants
# ------------------------------------------------------------------------------

gmt gmtset FONT_LABEL               = 12

gmt gmtset MAP_FRAME_PEN            = 0.75p,black
gmt gmtset MAP_FRAME_WIDTH          = 0.75p
gmt gmtset MAP_TICK_PEN_PRIMARY     = 0.75p
gmt gmtset MAP_GRID_PEN_PRIMARY     = 0.75p
gmt gmtset MAP_TICK_PEN_PRIMARY     = 0.75p
gmt gmtset MAP_TICK_LENGTH_PRIMARY  = 6p/3p
gmt gmtset MAP_LABEL_OFFSET         = 8p
gmt gmtset MAP_ANNOT_OFFSET_PRIMARY = 5p

# Read arguments
# ------------------------------------------------------------------------------

     RUN=$1
  METRIC=$2
   TITLE=$3
  COLUMN=$4
MAXCOUNT=$5
FNAME=$6

# Assign static files data
# ------------------------------------------------------------------------------

DATADIR=./cluster_data

THESCORES=${DATADIR}/${FNAME}.txt
SHORE=${DATADIR}/xy-shoreline.txt
EPICENTER=${DATADIR}/xy-epicenter.txt

# Setup local constants
# ------------------------------------------------------------------------------

SCORES=scores.tmp
DISTA=dista.tmp
CPTFILE=gof.cpt
OUTPUT=${RUN}-${METRIC}.ps
STATIONS=stations.tmp
MEDIA=media.tmp
STDDEV=stddev.tmp

# Captures the columns necessary for plotting and prints local files
# ------------------------------------------------------------------------------

awk -F' ' '{print $2, $3, $'$COLUMN'}' $THESCORES > $SCORES
awk -F' ' '{print $4, $'$COLUMN'}' $THESCORES > $DISTA
awk -F' ' '{print $2, $3}' $THESCORES > $STATIONS

# Computes the media of all stations and prints to file
# ------------------------------------------------------------------------------

awk '{
    s+=$'$COLUMN'
} END {
    media=s/NR
} END {
    print "0 " media, "\n140 " media
}' $THESCORES > $MEDIA

# Computes the +-1 standard deviation and prints to file
# ------------------------------------------------------------------------------

awk '{
    sum += $'$COLUMN'; 
    sumsq += $'$COLUMN'*$'$COLUMN';
    media = sum/NR;
    sdev = sqrt(sumsq/NR - media^2);
    top = media + sdev;
    bottom = media - sdev;
} END {
    print "0 " bottom, "\n0 " top, "\n140 " top, "\n140 " bottom 
}' $THESCORES > $STDDEV

# Prepares Color Palette file
# ------------------------------------------------------------------------------

# makecpt -Chaxby -D -T0/10/0.5 > $CPTFILE

# Computes the grid for plotting the scores
# ------------------------------------------------------------------------------

gmt surface $SCORES -Ggof.grd -I100 -R0/180000/0/135000 -C0.01 -T0.1

# Histogram and colorbar
# ------------------------------------------------------------------------------

gmt psbasemap -JX5.4i/1.5i -Bens -R0/10/0/100 -X1.5i -Y2i -K -P > $OUTPUT

gmt psbasemap -J -Ba10f5:"Count":W -R0/10/0/$MAXCOUNT -K -O >> $OUTPUT

gmt gmtset MAP_TICK_LENGTH_PRIMARY = 0p
gmt psbasemap -J -Bf100wsne -R -K -O >> $OUTPUT

gmt pshistogram $SCORES -i2 -W0.5 -Lthinner -R -J -C$CPTFILE -V -K -O >> $OUTPUT

gmt gmtset MAP_GRID_PEN_PRIMARY = 0.5p,black,_
gmt gmtset MAP_TICK_LENGTH_PRIMARY = 6p/3p

gmt psscale -C$CPTFILE -B1g0.5:"Score": -D2.7i/0i/5.4i/0.25ih -Y-0.2i -V -K -O >> $OUTPUT

# Surface map
# ------------------------------------------------------------------------------

gmt psbasemap -JX5.4i/4.05i -Bwesn -R0/180000/0/135000 -Y1.9i -K -O >> $OUTPUT

#gmt grdimage gof.grd -J -B -C$CPTFILE -V -K -O >> $OUTPUT
gmt grdview gof.grd -J -B -C$CPTFILE -Qi210 -V -K -O >> $OUTPUT

gmt psxy $SHORE -R -J -Wthin -G164/211/238 -V -K -O >> $OUTPUT

gmt psxy $STATIONS -R -J -Sc2p -Ggray -Wthinner -V -K -O >> $OUTPUT

gmt psxy $EPICENTER -R -J -Sa15p -Gwhite -Wthin -V -K -O >> $OUTPUT

gmt gmtset MAP_TICK_LENGTH_PRIMARY = 0p
gmt psbasemap -J -Bf180000wesn -R -K -O >> $OUTPUT

# Socores vs epicentral distance
# ------------------------------------------------------------------------------

gmt gmtset MAP_GRID_PEN_PRIMARY = 0.5p,50,.

gmt psbasemap -JX5.4i/1.5i -R0/140/0/10 -B -Y4.25i -V -K -O >> $OUTPUT

gmt psxy $STDDEV -J -R -G220 -V -K -O >> $OUTPUT

gmt gmtset MAP_TICK_LENGTH_PRIMARY = 6p/3p
gmt psbasemap -J -R -Bg10/g2 -V -K -O >> $OUTPUT

gmt gmtset MAP_LABEL_OFFSET        = 12p
gmt psxy $DISTA -J -R -Ba10:"Epicentral Distance (km)":/a2f1:"Score":WN -Wthick,0/0/200 -V -K -O >> $OUTPUT
gmt gmtset MAP_LABEL_OFFSET        = 8p

gmt psxy $MEDIA -J -R -W0.75p,black -V -K -O >> $OUTPUT

# Title
# ------------------------------------------------------------------------------

gmt pstext -R -J -N -O >> $OUTPUT << TEXT
70 15 12 0.0 1 CB ${TITLE} - ${METRIC}
# 70 15 12 0.0 1 CB ${CVM} ${TITLE}
TEXT

# Converting to EPS and PDF
# ------------------------------------------------------------------------------

gmt ps2raster $OUTPUT -Tf

# Opening PDF
# ------------------------------------------------------------------------------

#open -a Adobe\ Acrobat\ Pro.app ${RUN}-${METRIC}.pdf

rm ${OUTPUT}
rm gof.grd
rm *.tmp
