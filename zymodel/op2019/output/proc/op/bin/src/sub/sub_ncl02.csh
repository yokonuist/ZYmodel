#!/usr/bin/csh -f

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

set run_dir    = `pwd`

cd ${run_dir}
set file =(`ls -1 wrfout_d01*`)
set len=$#file

#slp
if(! -d ${run_dir}/fig/slp )then
mkdir -p ${run_dir}/fig/slp
endif
wait

set i = 1
set j = 0
while($i <= $len)
if($j <= 99) set lab_fcst = $j
if($j <= 9) set lab_fcst = 0$j
if(-f ${run_dir}/tmp02.ncl) rm ${run_dir}/tmp02.ncl
if(-f ${run_dir}/slp.000002.png) rm ${run_dir}/slp.000002.png

cp -rf $outputworkdir/bin/src/slp.ncl ${run_dir}/tmp02.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/tmp02.ncl
ncl ${run_dir}/tmp02.ncl >& ${run_dir}/tmp02.log
rm ${run_dir}/slp.000001.png
mv ${run_dir}/slp.000002.png ${run_dir}/fig/slp/${lab_fcst}.png
@ j = $j + 3
@ i = $i + 1
end

wait

exit
