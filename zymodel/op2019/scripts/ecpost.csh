#!/usr/bin/csh -f

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

#---------------------------------------------------------------------------------------------
#  Main routines that calls the benchmarkfunctions
#        and run in a parallel way
#        Edited by Guoyk, 8.15
# e.g.) $0 2019081300 2019081700 /public/home/henanqx/MDT/Guoyk/op2019/output/fc/ctl/2019081300/ >& test.log &
#---------------------------------------------------------------------------------------------- 
 
set startdate  = $1
set enddate    = $2

#----- initailize sub_functions to define running rules
#----- e.g.> sub_01 define ctl rundirs rules and out dirs
echo " Using cycles to define post rules"

cd ${outputworkdir}

# initialization ctl
cat > sub_post_01.csh << "EOF"
#!/usr/bin/csh -f
set prefix     = ctl
set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

set startdate  = tmp1
set stopdate   = tmp2
set fcdirs     = ${ctlfcdir}/${startdate}
set outdirncl  = ${ctlfigdir}
set outdirm4   = ${ctlm4dir}

if(! -d ${outputworkdir}/working)then
sleep 5 
mkdir -p ${outputworkdir}/working
endif
wait

set base_dir   = ${outputworkdir}/working/${prefix}

if(-d ${base_dir})then
rm -rf ${base_dir}
endif
wait

mkdir -p ${base_dir}/work01 #for ncl
wait

mkdir -p ${base_dir}/work02 #for m4
wait

cd ${base_dir}/work01
cp -rf ${outputworkdir}/bin/postncl.csh ${base_dir}/work01 
wait

${base_dir}/work01/postncl.csh $startdate $stopdate $fcdirs >& ${base_dir}/work01/postncl.log &
wait

cd ${base_dir}/work02
cp -rf ${outputworkdir}/bin/postm4.csh ${base_dir}/work02
wait

${base_dir}/work02/postm4.csh $startdate $stopdate $fcdirs >& ${base_dir}/work02/postm4.log &
wait

# wait files
while(! -f ${base_dir}/work02/SUCCESS_m4.log || ! -f ${base_dir}/work01/SUCCESS_ncl.log)
sleep 5
end
wait

# Check and copy outputs
if(-f ${base_dir}/work02/SUCCESS_m4.log && -f ${base_dir}/work01/SUCCESS_ncl.log)then
echo "run ok" >& $outputdir/proc/SUCCESS_${prefix}.log
mkdir -p $ctlfigdir/$startdate
mkdir -p $ctlm4dir
cp -rf ${base_dir}/work01/fig/* $ctlfigdir/$startdate
cp -rf ${base_dir}/work02/$startdate/* $ctlm4dir
else
exit 1
endif
wait

exit

"EOF"

set tmp1 = `${wrfworkdir}/bin/datetime.exe $startdate 0`   # 12 hour is ok
set tmp2 = `${wrfworkdir}/bin/datetime.exe $startdate 4d` # 3day and 12hour is ok

sed -i "s/set startdate  = tmp1/set startdate  = $tmp1/g" ${outputworkdir}/sub_post_01.csh
sed -i "s/set stopdate   = tmp2/set stopdate   = $tmp2/g" ${outputworkdir}/sub_post_01.csh

chmod -R 755 ${outputworkdir}/sub_post_01.csh

# initialization eme
cat > sub_post_02.csh << "EOF"
#!/usr/bin/csh -f
set prefix     = eme
set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

set startdate  = tmp1
set stopdate   = tmp2
set fcdirs     = ${emefcdir}/${startdate}
set outdirncl  = ${emefigdir}
set outdirm4   = ${emem4dir}

if(! -d ${outputworkdir}/working)then
sleep 5
mkdir -p ${outputworkdir}/working
endif
wait

set base_dir   = ${outputworkdir}/working/${prefix}

if(-d ${base_dir})then
rm -rf ${base_dir}
endif
wait

mkdir -p ${base_dir}/work01 #for ncl
wait

mkdir -p ${base_dir}/work02 #for m4
wait

cd ${base_dir}/work01
cp -rf ${outputworkdir}/bin/postncl.csh ${base_dir}/work01
wait

${base_dir}/work01/postncl.csh $startdate $stopdate $fcdirs >& ${base_dir}/work01/postncl.log &
wait

cd ${base_dir}/work02
cp -rf ${outputworkdir}/bin/postm4.csh ${base_dir}/work02
wait

${base_dir}/work02/postm4.csh $startdate $stopdate $fcdirs >& ${base_dir}/work02/postm4.log &
wait

#wait files sleep 30s 
while(! -f ${base_dir}/work02/SUCCESS_m4.log || ! -f ${base_dir}/work01/SUCCESS_ncl.log)
sleep 5
end
wait

# Check and copy outputs
 if(-f ${base_dir}/work02/SUCCESS_m4.log && -f ${base_dir}/work01/SUCCESS_ncl.log)then
 echo "run ok" >&  $outputdir/proc/SUCCESS_${prefix}.log
 mkdir -p $emefigdir/$startdate
 mkdir -p $emem4dir
 cp -rf ${base_dir}/work01/fig/* $emefigdir/$startdate
 cp -rf ${base_dir}/work02/$startdate/* $emem4dir
 else
 exit 1
 endif
 wait

 exit

"EOF"


set tmp1 = `${wrfworkdir}/bin/datetime.exe $startdate 12h`   # 12 hour is ok
set tmp2 = `${wrfworkdir}/bin/datetime.exe $startdate 3d12h` # 3day and 12hour is ok

sed -i "s/set startdate  = tmp1/set startdate  = $tmp1/g" ${outputworkdir}/sub_post_02.csh
sed -i "s/set stopdate   = tmp2/set stopdate   = $tmp2/g" ${outputworkdir}/sub_post_02.csh

chmod -R 755 ${outputworkdir}/sub_post_02.csh


 set i = 1
 while($i <= 2)
# check if everything is ok as "time" command is replaced? 8.14 
 ${outputworkdir}/sub_post_0${i}.csh >& ${outputworkdir}/0${i}.log &
 @ i = $i + 1
 end
# need about 8min to finish
 sleep 8m
 wait


if(-f $outputdir/proc/SUCCESS_ctl.log && -f $outputdir/proc/SUCCESS_eme.log)then
echo  "RUN OK" >& $outputdir/SUCCESS_out.log
exit 0 
else
exit 1
endif


exit

