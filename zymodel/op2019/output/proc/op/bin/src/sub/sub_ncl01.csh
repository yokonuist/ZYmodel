#!/usr/bin/csh -f

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

set run_dir    = `pwd`

cd ${run_dir}
set file =(`ls -1 wrfout_d01*`)
set len=$#file

#- 1file plot as t2,slp,radarref,vis,accumpcp,10mwinds, t2max, and pcptype
#-   can be handled with a parallel way
if(! -d ${run_dir}/fig/t2 )then
mkdir -p ${run_dir}/fig/t2
endif
 #--handle filename with datetime or with j
set i = 1
set j = 0
while($i <= $len)
if($j <= 99) set lab_fcst = $j
if($j <= 9) set lab_fcst = 0$j
if(-f ${run_dir}/tmp01.ncl) rm ${run_dir}/tmp01.ncl
if(-f ${run_dir}/T2C.000002.png) rm ${run_dir}/T2C.000002.png

cp -rf $outputworkdir/bin/src/T2_1f.ncl ${run_dir}/tmp01.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/tmp01.ncl
ncl ${run_dir}/tmp01.ncl >& ${run_dir}/tmp01.log
rm ${run_dir}/T2C.000001.png
mv ${run_dir}/T2C.000002.png ${run_dir}/fig/t2/${lab_fcst}.png
@ j = $j + 3
@ i = $i + 1
end

wait

exit
