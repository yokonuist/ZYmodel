#!/bin/csh -f
#rm *.bz2
#cp ../../../ec/raw/W_NAFP_C_ECMF_201903270*C1*.bz2 ./
#bzip2 -d *.bz2

set file=(`ls -1 W_NAFP_C_ECMF*C1*1`)
set len=$#file

rm *.grib1

set i = 1
while($i <= $len)

echo $i ok  $file[$i]

./grib_copy -v -w edition=1 ${file[$i]} ${file[$i]}.grib1

@ i = $i + 1

end

./link_grib.csh W_NAFP_C_ECMF*.grib1
