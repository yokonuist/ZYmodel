#!/usr/bin/csh -f

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

set run_dir    = `pwd`
set nowdate    = $1

cd ${run_dir}/
set file =(`ls -1 wrfout_d01*`)
set len=$#file

#pcp24
if(! -d ${run_dir}/fig/pcp24)then
mkdir -p ${run_dir}/fig/pcp24
endif
wait

#--- get 24h rainfile
#--- 

mkdir -p ${run_dir}/24hf
wait

if(-f ${run_dir}/24hf/00.nc)then
rm ${run_dir}/24hf/*.nc
endif

cd ${run_dir}/24hf
set i = 1
set j = 0
set k = 0
while($i <= $len)
if($k <= 99) set labk = $k
if($k <= 9)  set labk = 0$k
if($j == 0 || $j == 24 || $j == 48 || $j == 72 || $j == 96)then
echo ${file[$i]}
cp -rf ${run_dir}/${file[$i]} ${run_dir}/24hf/$labk.nc
@ k = $k + 1
endif
@ j = $j + 3
@ i = $i + 1
end
wait

# get 00 01 02 03 files
# by using pcp diff 01=24h 02=48h
cp ${outputworkdir}/bin/caculate_sum_rain/wrfpcpdiff.exe ${run_dir}/24hf
wait
cp ${outputworkdir}/bin/caculate_sum_rain/wrf_pcp.nl ${run_dir}/24hf
wait

cd ${run_dir}/24hf
set file =(`ls -1 *.nc`)
set len=$#file
@ end = ${len} - 1
set i = $end
echo $i

while($i >= 1  && $i <= $end)
if(-f ${run_dir}/24hf/pcp1f.000002.png)then
 rm ${run_dir}/24hf/pcp1f.000002.png
endif

@ j = $i - 1
echo $j

if($j <= 99) set labj = $j
if($j <= 9)  set labj = 0$j
if($i <= 99) set labi = $i
if($i <= 9)  set labi = 0$i


${run_dir}/24hf/wrfpcpdiff.exe ${run_dir}/24hf/${labi}.nc ${run_dir}/24hf/${labj}.nc >& ${run_dir}/24hf/tmp_${labi}.log # labi file contains 24 accum rain
cp -rf $outputworkdir/bin/src/rainc_1f.ncl ${run_dir}/24hf/pcp02.ncl
sed -i "s/f2/${labi}.nc/" ${run_dir}/24hf/pcp02.ncl

@ ke = $i * 24
@ ks = $j * 24
set sh1 = "24"
set sh2 = `$wrfworkdir/bin/datetime.exe $nowdate $ks`
set sh3 = `$wrfworkdir/bin/datetime.exe $nowdate $ke`
echo $sh2 $sh3 $ke $ks
sed -i "s/tmp1-hour Total Precipitation:tmp2 TO tmp3/$sh1-hour Total Precipitation:$sh2 TO $sh3/" ${run_dir}/24hf/pcp02.ncl

ncl ${run_dir}/24hf/pcp02.ncl >& ${run_dir}/24hf/pcp02.log
rm ${run_dir}/24hf/pcp1f.000001.png
mv ${run_dir}/24hf/pcp1f.000002.png ${run_dir}/fig/pcp24/${sh3}.png

@ i = $i - 1
end

wait


exit
