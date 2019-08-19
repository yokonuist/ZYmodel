#!/usr/bin/csh -f

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

set run_dir    = `pwd`

cd ${run_dir}
set file =(`ls -1 wrfout_d01*`)
set len=$#file

#10mwinds
if(! -d ${run_dir}/fig/10mwind)then
mkdir -p ${run_dir}/fig/10mwind
endif
wait

set i = 1
set j = 0
while($i <= $len)
if($j <= 99) set lab_fcst = $j
if($j <= 9) set lab_fcst = 0$j
if(-f ${run_dir}/tmp05.ncl) rm ${run_dir}/tmp05.ncl
if(-f ${run_dir}/10mWinds.000002.png) rm ${run_dir}/10mWinds.000002.png

cp -rf $outputworkdir/bin/src/Wind10m.ncl ${run_dir}/tmp05.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/tmp05.ncl
ncl ${run_dir}/tmp05.ncl >& ${run_dir}/tmp05.log
rm ${run_dir}/10mWinds.000001.png
mv ${run_dir}/10mWinds.000002.png ${run_dir}/fig/10mwind/${lab_fcst}.png
@ j = $j + 3
@ i = $i + 1
end

wait

exit
