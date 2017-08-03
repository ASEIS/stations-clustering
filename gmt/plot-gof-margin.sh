
clear

set -x

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

# Assign static files data
# ------------------------------------------------------------------------------

DATADIR=./

# THESCORES=/Users/shima/Documents/Shima/Research/score/${METRIC}/${RUN}/scores.txt
# SHORE=${DATADIR}/xy-shoreline.txt
# EPICENTER=/Users/shima/Documents/Shima/RA-Work/Results/${METRIC}/xy-epicenter.txt

THESCORES=sample-scores.txt
SHORE=xy-shoreline.txt
EPICENTER=xy-epicenter.txt

# Setup local constants
# ------------------------------------------------------------------------------

SCORES=scores.tmp
DISTA=dista.tmp
CPTFILE=gof.cpt

# OUTPUT=/Users/shima/Documents/Shima/Research/GOF-plot/${METRIC}/${RUN}/2-${RUN}-${METRIC}-${COLUMN}.ps
OUTPUTNAME=goftest
OUTPUTFILE=${OUTPUTNAME}.ps

STATIONS=stations.tmp
MEDIA=media.tmp
STDDEV=stddev.tmp


# ==============================================================================================================
# PREPARING ALL THE DATA
# ==============================================================================================================


# Captures the columns necessary for plotting and prints local files
# ------------------------------------------------------------------------------

awk -F' ' '{print $3, $4, $'$COLUMN'}' $THESCORES > $SCORES
awk -F' ' '{print $5, $'$COLUMN'}' $THESCORES > $DISTA
awk -F' ' '{print $3, $4}' $THESCORES > $STATIONS

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


# ==============================================================================================================
# COMPLETE PLOT IN PDF
# ==============================================================================================================


# Computes the grid for plotting the scores
# ------------------------------------------------------------------------------

gmt surface $SCORES -Ggof.grd -I100 -R0/180000/0/135000 -C0.01 -T0.1

# Histogram and colorbar
# ------------------------------------------------------------------------------

gmt psbasemap -JX5.4i/1.5i -Bens -R0/10/0/100 -X1.5i -Y2i -K -P > ${OUTPUTFILE}
gmt psbasemap -J -Ba10f5:"Count":W -R0/10/0/$MAXCOUNT -K -O >> ${OUTPUTFILE}
gmt gmtset MAP_TICK_LENGTH_PRIMARY = 0p
gmt psbasemap -J -Bf100wsne -R -K -O >> ${OUTPUTFILE}
gmt pshistogram $SCORES -i2 -W0.5 -Lthinner -R -J -C$CPTFILE -V -K -O >> ${OUTPUTFILE}
gmt gmtset MAP_GRID_PEN_PRIMARY = 0.5p,black,_
gmt gmtset MAP_TICK_LENGTH_PRIMARY = 6p/3p
gmt psscale -C$CPTFILE -B1g0.5:"Score": -D2.7i/0i/5.4i/0.25ih -Y-0.2i -V -K -O >> ${OUTPUTFILE}

# Surface map
# ------------------------------------------------------------------------------

gmt psbasemap -JX5.4i/4.05i -Bwesn -R0/180000/0/135000 -Y1.9i -K -O >> ${OUTPUTFILE}
gmt grdview gof.grd -J -B -C$CPTFILE -Qi210 -V -K -O >> ${OUTPUTFILE}
gmt psxy $SHORE -R -J -Wthin -G164/211/238 -V -K -O >> ${OUTPUTFILE}
gmt psxy $STATIONS -R -J -Sc2p -Ggray -Wthinner -V -K -O >> ${OUTPUTFILE}
gmt psxy $EPICENTER -R -J -Sa15p -Gwhite -Wthin -V -K -O >> ${OUTPUTFILE}
gmt gmtset MAP_TICK_LENGTH_PRIMARY = 0p
gmt psbasemap -J -Bf180000wesn -R -K -O >> ${OUTPUTFILE}

# Title
# ------------------------------------------------------------------------------

gmt pstext -R -J -N -O >> ${OUTPUTFILE} << TEXT
TEXT

# Converting to EPS and PDF
# ------------------------------------------------------------------------------

gmt ps2raster ${OUTPUTFILE} -Tf -Au0.1cm -F${OUTPUTNAME}-full.pdf

# Opening PDF
# ------------------------------------------------------------------------------

# open -a Adobe\ Acrobat\ Pro.app /Users/shima/Documents/Shima/Research/GOF-plot/${METRIC}/${RUN}/2-${RUN}-${METRIC}-${COLUMN}.pdf
open -a Adobe\ Acrobat\ Pro.app ${OUTPUTNAME}-full.pdf


# ==============================================================================================================
# PLOT IN PDF WITHOUT THE RASTER
# ==============================================================================================================


gmt gmtset MAP_TICK_LENGTH_PRIMARY  = 6p/3p

# Computes the grid for plotting the scores
# ------------------------------------------------------------------------------

gmt surface $SCORES -Ggof.grd -I100 -R0/180000/0/135000 -C0.01 -T0.1

# Histogram and colorbar
# ------------------------------------------------------------------------------

gmt psbasemap -JX5.4i/1.5i -Bens -R0/10/0/100 -X1.5i -Y2i -K -P > ${OUTPUTFILE}
gmt psbasemap -J -Ba10f5:"Count":W -R0/10/0/$MAXCOUNT -K -O >> ${OUTPUTFILE}
gmt gmtset MAP_TICK_LENGTH_PRIMARY = 0p
gmt psbasemap -J -Bf100wsne -R -K -O >> ${OUTPUTFILE}
gmt pshistogram $SCORES -i2 -W0.5 -Lthinner -R -J -C$CPTFILE -V -K -O >> ${OUTPUTFILE}
gmt gmtset MAP_GRID_PEN_PRIMARY = 0.5p,black,_
gmt gmtset MAP_TICK_LENGTH_PRIMARY = 6p/3p
gmt psscale -C$CPTFILE -B1g0.5:"Score": -D2.7i/0i/5.4i/0.25ih -Y-0.2i -V -K -O >> ${OUTPUTFILE}

# Surface map
# ------------------------------------------------------------------------------

gmt psbasemap -JX5.4i/4.05i -Bwesn -R0/180000/0/135000 -Y1.9i -K -O >> ${OUTPUTFILE}
gmt psxy $SHORE -R -J -Wthin -G164/211/238 -V -K -O >> ${OUTPUTFILE}
gmt psxy $STATIONS -R -J -Sc2p -Ggray -Wthinner -V -K -O >> ${OUTPUTFILE}
gmt psxy $EPICENTER -R -J -Sa15p -Gwhite -Wthin -V -K -O >> ${OUTPUTFILE}
gmt gmtset MAP_TICK_LENGTH_PRIMARY = 0p
gmt psbasemap -J -Bf180000wesn -R -K -O >> ${OUTPUTFILE}

# Title
# ------------------------------------------------------------------------------

gmt pstext -R -J -N -O >> ${OUTPUTFILE} << TEXT
TEXT

# Converting to EPS and PDF
# ------------------------------------------------------------------------------

gmt ps2raster ${OUTPUTFILE} -Tf -Au0.1cm -F${OUTPUTNAME}-noraster.pdf

# Opening PDF
# ------------------------------------------------------------------------------

# open -a Adobe\ Acrobat\ Pro.app /Users/shima/Documents/Shima/Research/GOF-plot/${METRIC}/${RUN}/2-${RUN}-${METRIC}-${COLUMN}.pdf
open -a Adobe\ Acrobat\ Pro.app ${OUTPUTNAME}-noraster.pdf


# ==============================================================================================================
# PLOT IN PDF WITHOUT THE RASTER
# ==============================================================================================================


gmt gmtset MAP_TICK_LENGTH_PRIMARY  = 6p/3p

# Computes the grid for plotting the scores
# ------------------------------------------------------------------------------

gmt surface $SCORES -Ggof.grd -I100 -R0/180000/0/135000 -C0.01 -T0.1

# Surface map
# ------------------------------------------------------------------------------

gmt psbasemap -JX5.4i/4.05i -Bwesn -R0/180000/0/135000 -Y3.9i -K -P > ${OUTPUTFILE}
gmt grdview gof.grd -J -B -C$CPTFILE -Qi210 -V -K -O >> ${OUTPUTFILE}

# Title
# ------------------------------------------------------------------------------

gmt pstext -R -J -N -O >> ${OUTPUTFILE} << TEXT
TEXT

# Converting to EPS and PDF
# ------------------------------------------------------------------------------

gmt ps2raster ${OUTPUTFILE} -Tg -A -F${OUTPUTNAME}-raster.png

rm ${OUTPUTFILE} *.tmp *.conf *.history gof.grd

