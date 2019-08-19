#!/usr/bin/csh -f

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

#------------------------------------------------------------------------------------
# This is a benchmark ncl post shell with simple inputs such as startdate enddate and input dirs
#         , and output figs in its subdirs called ./fig
#                     Edited by Guoyk, 2019.8.14
#     This version is recommend to call with "&" signal
#------------------------------------------------------------------------------------

#------ ctl eme dac files are in specificed rules,
#------ the runs should be noted first
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

rm ${run_dir}/*.ncl
wait

#-begin plotting and output figs here
if(! -d ${run_dir}/fig )then
mkdir -p ${run_dir}/fig
endif
wait

cd ${run_dir}

cp -rf $outputworkdir/bin/src/sub/sub_ncl*.csh ${run_dir}
wait
#-------------------------------------------
#  Parallel way; t2 slp  vis etc.
#  Edited by Guoyk 2019.8.15
#--------------------------------------------

set file =(`ls -1 sub_ncl*.csh`)
set len=$#file

set i = 1
while($i <= $len)
if($i <= 99) set lab = $i
if($i <= 9)  set lab = 0$i
${run_dir}/sub_ncl${lab}.csh >& ${run_dir}/ncl${lab} &
@ i = $i + 1
end
wait

#t2max Not yet 8.14 :possible ncl06
#if(! -d ${run_dir}/fig/t2max)then
#mkdir -p ${run_dir}/fig/t2max
#endif
#wait
#pcptype Not yet 8.14: possible ncl07
#if(! -d ${run_dir}/fig/pcptype)then
#mkdir -p ${run_dir}/fig/pcptype
#endif
#wait

# 2file plot as rain of 24h 12h 6h and 3h 

cd ${run_dir}

cp -rf $outputworkdir/bin/src/sub/subpcp_ncl*.csh ${run_dir}
wait
#-------------------------------------------
#  Parallel way; pcp 3 6 12 24 accum etc.
#  #  Edited by Guoyk 2019.8.15
#  #--------------------------------------------
#
  set file =(`ls -1 subpcp_ncl*.csh`)
  set len=$#file

  set i = 1
  while($i <= $len)
  if($i <= 99) set lab = $i
  if($i <= 9)  set lab = 0$i

  ${run_dir}/subpcp_ncl${lab}.csh $nowdate >& ${run_dir}/pcpncl${lab} &
  @ i = $i + 1
  end
wait


#-----Check and touch SUCCESS files
  set file0 =(`ls -1 ${run_dir}/fig/pcp3/*.png`)
  set len0=$#file0
  set checkpcp3 = $len0 # pcp3 png files is lees

  set file1 =(`ls -1 ${run_dir}/wrfout_d01*`)
  set len1=$#file1
  @ checknum = $len1 - 1

if($checkpcp3 == $checknum)then
touch ${run_dir}/SUCCESS_ncl.log
echo "RUN ok" >& ${run_dir}/SUCCESS_ncl.log
endif
wait

exit 


