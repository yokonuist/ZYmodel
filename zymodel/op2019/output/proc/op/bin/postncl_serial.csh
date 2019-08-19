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
if(-f ${run_dir}/tmp.ncl) rm ${run_dir}/tmp.ncl
if(-f ${run_dir}/T2C.000002.png) rm ${run_dir}/T2C.000002.png

cp -rf $outputworkdir/bin/src/T2_1f.ncl ${run_dir}/tmp.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/tmp.ncl
ncl ${run_dir}/tmp.ncl >& tmp.log 
rm T2C.000001.png
mv T2C.000002.png ${run_dir}/fig/t2/${lab_fcst}.png
@ j = $j + 3
@ i = $i + 1
end

wait

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
if(-f ${run_dir}/tmp.ncl) rm ${run_dir}/tmp.ncl
if(-f ${run_dir}/slp.000002.png) rm ${run_dir}/slp.000002.png

cp -rf $outputworkdir/bin/src/slp.ncl ${run_dir}/tmp.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/tmp.ncl
ncl ${run_dir}/tmp.ncl >& tmp.log 
rm slp.000001.png
mv slp.000002.png ${run_dir}/fig/slp/${lab_fcst}.png
@ j = $j + 3
@ i = $i + 1
end

wait


#radarref
if(! -d ${run_dir}/fig/ref )then
mkdir -p ${run_dir}/fig/ref
endif
wait

set i = 1
set j = 0
while($i <= $len)
if($j <= 99) set lab_fcst = $j
if($j <= 9) set lab_fcst = 0$j
if(-f ${run_dir}/tmp.ncl) rm ${run_dir}/tmp.ncl
if(-f ${run_dir}/mdbz.000002.png) rm ${run_dir}/mdbz.000002.png

cp -rf $outputworkdir/bin/src/Radarref.ncl ${run_dir}/tmp.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/tmp.ncl
ncl ${run_dir}/tmp.ncl >& tmp.log 
rm mdbz.000001.png
mv mdbz.000002.png ${run_dir}/fig/ref/${lab_fcst}.png
@ j = $j + 3
@ i = $i + 1
end

wait

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
if(-f ${run_dir}/tmp.ncl) rm ${run_dir}/tmp.ncl
if(-f ${run_dir}/vis.000002.png) rm ${run_dir}/vis.000002.png

cp -rf $outputworkdir/bin/src/vis.ncl ${run_dir}/tmp.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/tmp.ncl
ncl ${run_dir}/tmp.ncl >& tmp.log 
rm vis.000001.png
mv vis.000002.png ${run_dir}/fig/vis/${lab_fcst}.png
@ j = $j + 3
@ i = $i + 1
end

wait

# 10mwinds
if(! -d ${run_dir}/fig/10mwind)then
mkdir -p ${run_dir}/fig/10mwind
endif
wait

set i = 1
set j = 0
while($i <= $len)
if($j <= 99) set lab_fcst = $j
if($j <= 9) set lab_fcst = 0$j
if(-f ${run_dir}/tmp.ncl) rm ${run_dir}/tmp.ncl
if(-f ${run_dir}/10mWinds.000002.png) rm ${run_dir}/10mWinds.000002.png

cp -rf $outputworkdir/bin/src/Wind10m.ncl ${run_dir}/tmp.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/tmp.ncl
ncl ${run_dir}/tmp.ncl >& tmp.log 
rm 10mWinds.000001.png
mv 10mWinds.000002.png ${run_dir}/fig/10mwind/${lab_fcst}.png
@ j = $j + 3
@ i = $i + 1
end

wait

# accumpcp
if(! -d ${run_dir}/fig/accumpcp)then
mkdir -p ${run_dir}/fig/accumpcp
endif
wait

set i = 1
set j = 0
while($i <= $len)
if($j <= 99) set lab_fcst = $j
if($j <= 9) set lab_fcst = 0$j
if(-f ${run_dir}/tmp.ncl) rm ${run_dir}/tmp.ncl
if(-f ${run_dir}/tmp.log) rm ${run_dir}/tmp.log
if(-f ${run_dir}/pcp1f.000002.png) rm ${run_dir}/pcp1f.000002.png

if($j == 24 || $j == 48 || $j == 72 || $j == 96)then
cp -rf $outputworkdir/bin/src/rain_1f.ncl ${run_dir}/tmp.ncl
set files = ${file[$i]}
echo $files  $j
sed -i "s/f2/$files/" ${run_dir}/tmp.ncl
set sh1 = $j
set sh2 = `$wrfworkdir/bin/datetime.exe $nowdate 0`
set sh3 = `$wrfworkdir/bin/datetime.exe $nowdate $j`
sed -i "s/tmp1-hour Total Precipitation:tmp2 TO tmp3/$sh1-hour Total Precipitation:$sh2 TO $sh3/" ${run_dir}/tmp.ncl
ncl ${run_dir}/tmp.ncl >& tmp.log 
rm pcp1f.000001.png
mv pcp1f.000002.png ${run_dir}/fig/accumpcp/${lab_fcst}.png
endif

@ j = $j + 3
@ i = $i + 1
end

wait


#t2max Not yet 8.14
if(! -d ${run_dir}/fig/t2max)then
mkdir -p ${run_dir}/fig/t2max
endif
wait
#pcptype Not yet 8.14
if(! -d ${run_dir}/fig/pcptype)then
mkdir -p ${run_dir}/fig/pcptype
endif
wait

# 2file plot as rain of 24h 12h 6h and 3h 
#24rain
if(! -d ${run_dir}/fig/pcp24 )then
mkdir -p ${run_dir}/fig/pcp24
endif
wait

#12rain
if(! -d ${run_dir}/fig/pcp12 )then
mkdir -p ${run_dir}/fig/pcp12
endif
wait

#6rain
if(! -d ${run_dir}/fig/pcp6 )then
mkdir -p ${run_dir}/fig/pcp6
endif
wait

#3rain
if(! -d ${run_dir}/fig/pcp3 )then
mkdir -p ${run_dir}/fig/pcp3
endif
wait

#-----Check and touch SUCCESS files

exit 


