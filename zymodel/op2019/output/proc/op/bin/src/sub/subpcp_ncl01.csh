#!/usr/bin/csh -f

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

set run_dir    = `pwd`
set nowdate    = $1

cd ${run_dir}
set file =(`ls -1 wrfout_d01*`)
set len=$#file

#accumpcp
if(! -d ${run_dir}/fig/accumpcp)then
mkdir -p ${run_dir}/fig/accumpcp
endif
wait

set i = 1
set j = 0
while($i <= $len)
if($j <= 99) set lab_fcst = $j
if($j <= 9) set lab_fcst = 0$j
if(-f ${run_dir}/pcp01.ncl) rm ${run_dir}/pcp01.ncl
if(-f ${run_dir}/pcp01.log) rm ${run_dir}/pcp01.log
if(-f ${run_dir}/pcp1f.000002.png) rm ${run_dir}/pcp1f.000002.png

if($j == 24 || $j == 48 || $j == 72 || $j == 96)then
cp -rf $outputworkdir/bin/src/rain_1f.ncl ${run_dir}/pcp01.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/pcp01.ncl
set sh1 = $j
set sh2 = `$wrfworkdir/bin/datetime.exe $nowdate 0`
set sh3 = `$wrfworkdir/bin/datetime.exe $nowdate $j`
sed -i "s/tmp1-hour Total Precipitation:tmp2 TO tmp3/$sh1-hour Total Precipitation:$sh2 TO $sh3/" ${run_dir}/pcp01.ncl
ncl ${run_dir}/pcp01.ncl >& ${run_dir}/pcp01.log
rm ${run_dir}/pcp1f.000001.png
mv ${run_dir}/pcp1f.000002.png ${run_dir}/fig/accumpcp/${lab_fcst}.png
endif

@ j = $j + 3
@ i = $i + 1

end

wait

exit
