#!/usr/bin/csh -f
set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs 

#------------------------------------------------------------------------------------
# This is a benchmark wrfcnv post shell with simple inputs such as startdate enddate and input dirs
#         , and output figs in its subdirs called ./d01
#                     Edited by Guoyk, 2019.8.14
#     This version is recommend to call with "&" signal
#------------------------------------------------------------------------------------


set nowdate    = $1
set enddate    = $2
set fc_dirs    = $3
set run_dir    = `pwd`

if(! -d $fc_dirs)then
exit 1
endif

#rsync copy wrfout d01 files here
cd ${fc_dirs}
set file =(`ls -1 wrfout_d01*`)
set len=$#file

set i = 1
while($i <= $len)
#echo $i ok  $file[$i] get grib1 file
cp ${fc_dirs}/${file[$i]} ${run_dir} &
@ i = $i + 1
end
wait

cd ${run_dir}
# copy that we need
cp ${outputworkdir}/bin/wrfcnv/*.exe ${run_dir}
#cp ${outputworkdir}/bin/wrfcnv/namelist.post ${run_dir} #not now
cp ${outputworkdir}/bin/caculate_sum_rain/*.exe ${run_dir}
cp ${outputworkdir}/bin/caculate_sum_rain/wrf_pcp.nl ${run_dir}
wait

set i = 1
set j = 0
while($i <= $len)
# doing sum
${run_dir}/wrfpcpsum.exe ${run_dir}/$file[$i] >& ${run_dir}/pcpsum.log & # get rainnc files 
@ i = $i + 1
end
wait

# fix date
# set fixdate = `$wrfworkdir/bin/datetime.exe $nowdate -w`

set i = 1
set j = 0
while($i <= $len)
if( $j <= 99 ) set lab_j = 0$j
 if( $j <= 9 ) set lab_j = 00$j
cp ${outputworkdir}/bin/wrfcnv/namelist.m4 ${run_dir}/namelist
sed -i "s/wrfout_d01_2019-06-05_00:00:00/$file[$i]/g" ${run_dir}/namelist
sed -i "s/chlf_d01_<YYYY><MM><DD><HH>_024/wrf_d01_<YYYY><MM><DD><HH>_${lab_j}/g" ${run_dir}/namelist
cp ${run_dir}/namelist ${run_dir}/namelist.post
wait
${run_dir}/wrfcnv.exe >& ${run_dir}/cnv.log
wait
# move micaps4 data to where it belongs to.
mkdir -p ${run_dir}/$nowdate/RH2
mkdir -p ${run_dir}/$nowdate/T2
mkdir -p ${run_dir}/$nowdate/T2C
mkdir -p ${run_dir}/$nowdate/RAIN
mkdir -p ${run_dir}/$nowdate/WIND10
mkdir -p ${run_dir}/$nowdate/UA
mkdir -p ${run_dir}/$nowdate/VA
wait

cp -rf ${run_dir}/wrf_d01_${nowdate}_${lab_j}/RH2/* $run_dir/$nowdate/RH2
cp -rf ${run_dir}/wrf_d01_${nowdate}_${lab_j}/T2/* $run_dir/$nowdate/T2
cp -rf ${run_dir}/wrf_d01_${nowdate}_${lab_j}/T2C/* $run_dir/$nowdate/T2C
cp -rf ${run_dir}/wrf_d01_${nowdate}_${lab_j}/RAINNC/* $run_dir/$nowdate/RAIN
cp -rf ${run_dir}/wrf_d01_${nowdate}_${lab_j}/WIND10/* $run_dir/$nowdate/WIND10
cp -rf ${run_dir}/wrf_d01_${nowdate}_${lab_j}/UA/* $run_dir/$nowdate/UA
cp -rf ${run_dir}/wrf_d01_${nowdate}_${lab_j}/VA/* $run_dir/$nowdate/VA
wait
@ j = $j + 3 
@ i = $i + 1
end
wait

#-------------------------- Check and output SUCCESS Files
set file1 =(`ls -1 ${run_dir}/${nowdate}/WIND10/*`)
set len1=$#file1  # cnv outputs nums
echo $len $len1

if($len1 == $len)then
touch ${run_dir}/SUCCESS_m4.log
echo "Run OK" >& ${run_dir}/SUCCESS_m4.log
endif

wait


exit 0
