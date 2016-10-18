set terminal pngcairo size 700, 450
set output outfile
plot for[col=2:4] "<cat" using 1:col title columnheader(col) with lines