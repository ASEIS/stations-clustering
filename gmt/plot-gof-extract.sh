
clear

# Set GMT constants
# ------------------------------------------------------------------------------

gmtset FONT_LABEL               = 12

gmtset MAP_FRAME_PEN            = 0.75p,black
gmtset MAP_FRAME_WIDTH          = 0.75p
gmtset MAP_TICK_PEN_PRIMARY     = 0.75p
gmtset MAP_GRID_PEN_PRIMARY     = 0.75p
gmtset MAP_TICK_PEN_PRIMARY     = 0.75p
gmtset MAP_TICK_LENGTH_PRIMARY  = 6p/3p
gmtset MAP_LABEL_OFFSET         = 8p
gmtset MAP_ANNOT_OFFSET_PRIMARY = 5p

# Read arguments
# ------------------------------------------------------------------------------

CVM=$1
TITLE=$2
COLUMN=$3
MAXCOUNT=$4

XI=117000
XF=173000
YI=86000
YF=133000

  AZI=140
  ELE=80
PERSP=$AZI/$ELE

# Assign static files data
# ------------------------------------------------------------------------------

DATADIR=../data-plain

THESCORES=${DATADIR}/${CVM}-myscores.txt
SHORE=${DATADIR}/xy-shoreline.txt
EPICENTER=${DATADIR}/xy-epicenter.txt

# Setup local constants
# ------------------------------------------------------------------------------

SCORES=scores.tmp
DISTA=dista.tmp
CPTFILE=gof.cpt
OUTPUT=${CVM}-${TITLE}.ps
STATIONS=stations.tmp
MEDIA=media.tmp
STDDEV=stddev.tmp

# Captures the columns necessary for plotting and prints local files
# ------------------------------------------------------------------------------

awk -F' ' '{print $3, $4, $'$COLUMN'}' $THESCORES > $SCORES
awk -F' ' '{print $3, $4}' $THESCORES > $STATIONS

# Computes the grid for plotting the scores
# ------------------------------------------------------------------------------

surface $SCORES -Ggof.grd -I100 -R0/180000/0/135000 -C0.01 -T0.1

# Surface map
# ------------------------------------------------------------------------------

psbasemap -JX5i/3.7i -Bwesn -R${XI}/${XF}/${YI}/${YF} -p$PERSP/0 -Y5i -P -K >> $OUTPUT

grdview gof.grd -J -B -C$CPTFILE -Qi150 -p -V -K -O >> $OUTPUT

psxy $SHORE -R -J -Wthin -G164/211/238 -p -V -K -O >> $OUTPUT

psxy $STATIONS -R -J -Sc2p -Ggray -Wthinner -p -V -K -O >> $OUTPUT

psxy $EPICENTER -R -J -Sa10p -Gblack -Wthin -p -V -K -O >> $OUTPUT

gmtset MAP_TICK_LENGTH_PRIMARY = 0p
psbasemap -J -Bf180000wesn -R -p -O >> $OUTPUT

# Converting to EPS and PDF
# ------------------------------------------------------------------------------

ps2raster $OUTPUT -Tf

# Opening PDF
# ------------------------------------------------------------------------------

open -a Adobe\ Acrobat\ Pro.app ${CVM}-${TITLE}.pdf

rm ${OUTPUT}
rm gof.grd
rm *.tmp
