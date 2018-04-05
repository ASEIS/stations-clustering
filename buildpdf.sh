
MAIN=$1

pdflatex ${MAIN}.tex
bibtex   ${MAIN}.aux
pdflatex ${MAIN}.tex
pdflatex ${MAIN}.tex

rm ${MAIN}.fff ${MAIN}.log ${MAIN}.aux ${MAIN}.ttt ${MAIN}.bbl ${MAIN}.lof ${MAIN}.blg ${MAIN}.spl ${MAIN}.out

mv ${MAIN}.pdf ${MAIN}.pdf

open -a Adobe\ Acrobat.app ${MAIN}.pdf

clear
