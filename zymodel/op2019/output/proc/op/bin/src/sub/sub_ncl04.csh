#!/usr/bin/csh -f

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

set run_dir    = `pwd`

cd ${run_dir}
set file =(`ls -1 wrfout_d01*`)
set len=$#file

#vis
if(! -d ${run_dir}/fig/vis )then
mkdir -p ${run_dir}/fig/vis
endif
wait

set i = 1
set j = 0
while($i <= $len)
if($j <= 99) set lab_fcst = $j
if($j <= 9) set lab_fcst = 0$j
if(-f ${run_dir}/tmp04.ncl) rm ${run_dir}/tmp04.ncl
if(-f ${run_dir}/vis.000002.png) rm ${run_dir}/vis.000002.png

cp -rf $outputworkdir/bin/src/vis.ncl ${run_dir}/tmp04.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/tmp04.ncl
ncl ${run_dir}/tmp04.ncl >& ${run_dir}/tmp04.log
rm ${run_dir}/vis.000001.png
mv ${run_dir}/vis.000002.png ${run_dir}/fig/vis/${lab_fcst}.png
@ j = $j + 3
@ i = $i + 1
end

wait

exit
