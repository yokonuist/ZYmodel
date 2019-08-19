#!/usr/bin/csh 

set nowdate    = $1
set enddate    = $2

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs
#source $envdir/envzymodels

#echo $wpsworkdir
#echo $wrfworkdir
#set wpsworkdir = /home/henanqx/MDT/Guoyk/op2019/wps/op
#set wrfworkdir    = /home/henanqx/MDT/Guoyk/op2019/wrf/op

set Tooldir    = ${wrfworkdir}/bin


# ------------------------------------------------------------
# Initialization of Model HenanLocal
# Generate sub functions
# Edited by Guoyk, 2019.8.10
#-------------------------------------------------------------


#-- running strages
# 0 means merge0 file ok
# 1 means merge1 file ok
# 2 means merge2 file ok
# 3 means merge3 file ok
 if(-f ${wrfworkdir}/initial.log)then
 rm ${wrfworkdir}/initial.log
 endif
 wait
# Possible Noah LSM is recomended 

 if(! -f ${wpsdir}/SUCCESS_merge0 && ! -f ${wpsdir}/SUCCESS_merge2 && ! -f ${wpsdir}/SUCCESS_merge3 )then
 echo CTL initialization ! >> ${wrfworkdir}/initial.log
 echo Not Enough Input datasets of met_em files: exitoffile >> ${wrfworkdir}/initial.log
 exit 1
 else if(! -f ${wpsdir}/SUCCES_merge2 && ! -f ${wpsdir}/SUCCES_merge3)then
 set strage = merge0
 echo CTL initialization ! >> ${wrfworkdir}/initial.log
 echo Strage: merge0  >> ${wrfworkdir}/initial.log
 else if(! -f ${wpsdir}/SUCCES_merge0 && ! -f ${wpsdir}/SUCCES_merge2)then 
 echo CTL initialization ! >> ${wrfworkdir}/initial.log
 echo Strage: merge3  >> ${wrfworkdir}/initial.log
 set strage = merge3
 else if(! -f ${wpsdir}/SUCCES_merge0 && ! -f ${wpsdir}/SUCCES_merge3)then
 echo CTL initialization ! >> ${wrfworkdir}/initial.log
 echo Strage: merge2  >> ${wrfworkdir}/initial.log
 set strage = merge2
 else # Possible Noah LSM is recomended 
 echo CTL initialization ! >> ${wrfworkdir}/initial.log
 echo Strage: merge0  >> ${wrfworkdir}/initial.log
 set strage = merge0
 endif
 wait
# final check  status should be noted at the first place
if(-f Timeinfo_${nowdate}.log)then
rm ${wrfworkdir}/Timeinfo_${nowdate}.log
endif
wait

cd ${wrfworkdir}

# 0 initial ctl run : time and dir
echo "01 initial ctl run : times and filedir"
cat > sub_01.csh <<"EOF"
#!/usr/bin/csh
set prefix     = ctl
set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs
set metfiles   = $wpsworkdir/working
#-- initilization of working envs
#- time settings
set startdate  = tmp1
set stopdate   = tmp2
#-- running strages default
set strage     = merge0
#- dirs settings

if(! -d ${wrfworkdir}/working)then
sleep 5
mkdir -p ${wrfworkdir}/working
endif
wait

set base_dir   = ${wrfworkdir}/working/${prefix}
if(-d ${base_dir})then
rm -rf ${base_dir}
endif
wait

mkdir -p ${base_dir}
wait

set merge_dir  = $metfiles/$strage

#-- define running rules
cd ${base_dir}
cp -rf bindir/* ${base_dir}
# run real and wrf | output: not support "&" sig
${base_dir}/real.csh $startdate $stopdate $merge_dir >& ${base_dir}/real.log 
wait

# Check Real SUCCESS FILE
 while(! -f ${base_dir}/SUCCESS_${startdate}_log)
 sleep 5
 end
 wait
 
if(! -d $ctlrcdir/$startdate)then
mkdir -p $ctlrcdir/$startdate
endif
cp -rf ${base_dir}/wrfinput* $ctlrcdir/$startdate
cp -rf ${base_dir}/wrfbdy* $ctlrcdir/$startdate

# Check Real SUCCESS FILE
if(-f ${base_dir}/SUCCESS_${startdate}_log)then
$scriptdir/clean.sh
sed -i 's#nodefile.txt#nodefile_ctl.txt#' ${base_dir}/wrf.pbs
/opt/tsce/torque6/bin/qsub ${base_dir}/wrf.pbs
sleep 20m
else
echo ${base_dir}/SUCCESS_${startdate}_log NOT EXSIST
exit 1
endif
wait

# need  30min to finish, Just sleep and awake 5min after
# Check if the wrfout of stopdate is ok
set ye = `echo $stopdate | cut -c 1-4`
set me = `echo $stopdate | cut -c 5-6`
set de = `echo $stopdate | cut -c 7-8`
set he = `echo $stopdate | cut -c 9-10`

# sleep 300s for Checking QSUB wrf RUN
while(! -f ${base_dir}/wrfout_d02_${ye}-${me}-${de}_${he}:00:00)
sleep 60
end
wait

 if(-f ${base_dir}/wrfout_d02_${ye}-${me}-${de}_${he}:00:00)then
 touch $wrfdir/SUCCESS_${prefix}.log
 mkdir -p $ctlfcdir/$startdate
 cp -rf ${base_dir}/wrfout* $ctlfcdir/$startdate 
 else
 exit 1
 endif
 wait

#if(! -d $ctlfcdir/$startdate)then
#mkdir -p $ctlfcdir/$startdate
#endif
#wait

#mv ${base_dir}/wrfout* $ctlfcdir/$startdate
#wait

exit 0

"EOF"
wait

set tmp1 = `${Tooldir}/datetime.exe $nowdate 0`
set tmp2 = `${Tooldir}/datetime.exe $nowdate 4d`

sed -i "s/set startdate  = tmp1/set startdate  = $tmp1/g" ${wrfworkdir}/sub_01.csh
sed -i "s/set stopdate   = tmp2/set stopdate   = $tmp2/g" ${wrfworkdir}/sub_01.csh
sed -i "s/set strage     = merge0/set strage     = ${strage}/g" ${wrfworkdir}/sub_01.csh
sed -i "s#cp -rf bindir#cp -rf ${Tooldir}#" ${wrfworkdir}/sub_01.csh
chmod -R 755 ${wrfworkdir}/sub_01.csh


#-----------------------------------
# 0 initial emergency run
echo "02 initial emergency run"
cat > sub_02.csh <<"EOF"
#!/usr/bin/csh -f
set prefix     = eme
set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs
set metfiles   = $wpsworkdir/working
#-- initilization of working envs
#- time settings
set startdate  = tmp1
set stopdate   = tmp2
#-- running strages default
set strage     = merge0
#- dirs settings

if(! -d ${wrfworkdir}/working)then
sleep 5 
mkdir -p ${wrfworkdir}/working
endif
wait

set base_dir   = ${wrfworkdir}/working/${prefix}

if(-d ${base_dir})then
rm -rf ${base_dir}
endif
wait

mkdir -p ${base_dir}
wait

set merge_dir  = $metfiles/$strage
#-- define running rules
 cd ${base_dir}
 cp -rf bindir/* ${base_dir}

# run real and wrf | output: not support "&" sig a
# as  we had made more choices to make runnings stable 
 ${base_dir}/real.csh $startdate $stopdate $merge_dir >& ${base_dir}/real.log 
 wait

# Check Real SUCCESS FILE
 while(! -f ${base_dir}/SUCCESS_${startdate}_log)
 sleep 5
 end
 wait

 if(! -d $emercdir/$startdate)then
 mkdir -p $emercdir/$startdate
 endif
 cp -rf ${base_dir}/wrfinput* $emercdir/$startdate
 cp -rf ${base_dir}/wrfbdy* $emercdir/$startdate

# Check real SUCCESS FILES
if(-f ${base_dir}/SUCCESS_${startdate}_log)then
sed -i 's#nodefile.txt#nodefile_eme.txt#' ${base_dir}/wrf.pbs
$scriptdir/clean.sh
/opt/tsce/torque6/bin/qsub ${base_dir}/wrf.pbs
sleep 20m
else
echo ${base_dir}/SUCCESS_${startdate}_log NOT EXSIST
exit 1
endif
wait

# need  30min to finish, Just sleep and awake 5min after
# # Check if the wrfout of stopdate is ok

set ye = `echo $stopdate | cut -c 1-4`
set me = `echo $stopdate | cut -c 5-6`
set de = `echo $stopdate | cut -c 7-8`
set he = `echo $stopdate | cut -c 9-10`

# sleep 300s for Checking QSUB wrf RUN
while(! -f ${base_dir}/wrfout_d02_${ye}-${me}-${de}_${he}:00:00)
sleep 60
end
wait
 
 if(-f ${base_dir}/wrfout_d02_${ye}-${me}-${de}_${he}:00:00)then
 touch $wrfdir/SUCCESS_${prefix}.log
 mkdir -p $emefcdir/$startdate
 cp -rf ${base_dir}/wrfout* $emefcdir/$startdate
 endif
 wait

# if(! -d $emefcdir/$startdate)then
# mkdir -p $emefcdir/$startdate
# endif
# wait

# mv ${base_dir}/wrfout* $emefcdir/$startdate
# wait

exit 0

"EOF"


set tmp1 = `${Tooldir}/datetime.exe $nowdate 12h`   # 12 hour is ok
set tmp2 = `${Tooldir}/datetime.exe $nowdate 3d12h` # 3day and 12hour is ok

sed -i "s/set startdate  = tmp1/set startdate  = $tmp1/g" ${wrfworkdir}/sub_02.csh
sed -i "s/set stopdate   = tmp2/set stopdate   = $tmp2/g" ${wrfworkdir}/sub_02.csh
sed -i "s/set strage     = merge0/set strage     = ${strage}/g" ${wrfworkdir}/sub_02.csh
sed -i "s#cp -rf bindir#cp -rf ${Tooldir}#" ${wrfworkdir}/sub_02.csh
chmod -R 755 ${wrfworkdir}/sub_02.csh
wait

# initial data assimilation cycle
cat > sub_03.csh <<"EOF"
#!/usr/bin/csh -f
set nowdate    = $1
set enddate    = $2
exit 0

"EOF"

wait

chmod -R 755 ${wrfworkdir}/sub_03.csh

echo -------------------------------------------------------------
echo  Run with the Parallel Way,  2019.8.10
echo -------------------------------------------------------------

# '>/dev/null 2>&1' seems very fast and quite impressive 
# But if only pids can be properly handled with wait

#foreach job (ctl eme)
#sleep 5s
#${wrfworkdir}/sub_ctl.csh >& ${wrfworkdir}/ctl.log 
#sleep 5s
#${wrfworkdir}/sub_eme.csh >& ${wrfworkdir}/eme.log

set i = 1
while($i <= 2)
# check if everything is ok as "time" command is replaced? 8.14 
${wrfworkdir}/sub_0${i}.csh >& ${wrfworkdir}/0${i}.log &
@ i = $i + 1
end
wait
#time ${wrfworkdir}/sub_ctl.csh >& ${wrfworkdir}/ctl.log &
#end # foreach has caused too much problem, not ok 

# Check SUCCESS FILES every 5min --- NO NEEDED, 2019.8.14 
#while(! -f $wrfdir/SUCCESS_ctl.log || ! -f $wrfdir/SUCCESS_eme.log)
#sleep 180
#end
#wait

# WAIT For The SUCCESS files OF ctl and eme
if(! -f $wrfdir/SUCCESS_ctl.log || ! -f $wrfdir/SUCCESS_eme.log)then
echo "ctl,eme Not Run OK" >& $wrfdir/FAIL_wrf.log
exit 1
else if(-f $wrfdir/SUCCESS_ctl.log && -f $wrfdir/SUCCESS_eme.log)then
echo  "RUN OK" >& $wrfdir/SUCCESS_wrf.log
exit 0 
# sometimes , ssh login cause  Problems as follows:
# Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).
# Thus, we need exit this shell form here
else
sleep 1 &
endif
wait

#--------------------------------------------------  Statistics
#foreach job (ctl eme)
#tail -n 3 ${wrfworkdir}/${job}.log >> ${wrfdir}/Timeinfo_wrf_${nowdate}.log
#echo ${job} Time Consuming: >> ${wrfdir}/Timeinfo_wrf_${nowdate}.log
#end # foreach
#----------------------------------------------- End Statistics 


# delete old files
#rm $wrfworkdir/sub*
#echo Finish Multi-JOBS

#while(-f ${wrfworkdir}/Timeinfo_${nowdate}.log)
#sleep 5
#exit 
#end

exit 
