#!/usr/bin/csh -f

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

# benchmark rules based on serveral basic inputs
# This version does not support backnodes, 
# Please Do not submit it with end signal of "&" on Zhengzhou University Super computer 
# --------------- By Guoyk, 2019.8.10
set nowdate    = $1
set enddate    = $2
set met_dirs   = $3
set run_dir    = `pwd`

# rysnc copy met files
cd ${met_dirs}
set file =(`ls -1 met_em.d0*`)
set len=$#file
set i = 1
while($i <= $len)
#echo $i ok  $file[$i] get grib1 file
cp ${met_dirs}/${file[$i]} ${run_dir} &
@ i = $i + 1
end
wait

cd ${run_dir}
#echo ${run_dir}
cp ${wrfworkdir}/bin/namelist ${run_dir}
# handle namelist

 set yy = `echo $nowdate |cut -c 1-4`
 set mm = `echo $nowdate |cut -c 5-6`
 set ds = `echo $nowdate |cut -c 7-8`
 set hs = `echo $nowdate |cut -c 9-10`

 set ye = `echo $enddate |cut -c 1-4`
 set me = `echo $enddate |cut -c 5-6`
 set de = `echo $enddate |cut -c 7-8`
 set he = `echo $enddate |cut -c 9-10`

sed -i "s/start_year = 2019, 2019,/start_year = $yy, $yy,/g" ${run_dir}/namelist
sed -i "s/start_month = 03, 03,/start_month = $mm, $mm,/g" ${run_dir}/namelist
sed -i "s/start_day = 27, 27,/start_day = $ds, $ds,/g" ${run_dir}/namelist
sed -i "s/start_hour = 00, 00,/start_hour = $hs, $hs,/g" ${run_dir}/namelist
sed -i "s/end_year = 2019, 2019,/end_year = $ye, $ye,/g" ${run_dir}/namelist
sed -i "s/end_month = 03, 03,/end_month = $me, $me,/g" ${run_dir}/namelist
sed -i "s/end_day = 30, 30,/end_day = $de, $de/g" ${run_dir}/namelist
sed -i "s/end_hour = 00, 00,/end_hour = $he, $he/g" ${run_dir}/namelist

# Run with two-way nested, thus, only wrfbdy_01 is generated
# If only one-way nested ,wrfbdy_d02 can be regenerated with ndown.exe
# The mpirun here should not submitted to the backnodes, found bugs !


if(-f ${run_dir}/wrfinput_d01 || -f ${run_dir}/wrfinput_d02 || -f ${run_dir}/wrfbdy_d01)then
rm ${run_dir}/wrfinput* ${run_dir}/wrfbdy*
endif
wait

# run with gfs levels, eg, 34 levs merge3
echo ${met_dirs} >& ${run_dir}/ch1 
grep -ir 'merge3' ${run_dir}/ch1 >& ${run_dir}/ch2
set checknum = `cat ${run_dir}/ch2 | wc -l`
rm ${run_dir}/ch*
if($checknum != 0)then
#echo run with gfs levs
sed -i "s/num_metgrid_levels = 20,/num_metgrid_levels = 34,/g" ${run_dir}/namelist
endif

# run with land options
cp ${run_dir}/namelist ${run_dir}/namelist.input
mpirun -np 10 ${run_dir}/real.exe >& ${run_dir}/real.log 
wait

if(! -f ${run_dir}/wrfinput_d01 || ! -f ${run_dir}/wrfinput_d02 || ! -f ${run_dir}/wrfbdy_d01 )then
#echo check 0
cp ${run_dir}/namelist ${run_dir}/namelist.input
# Assume not enough land data input and rerun 
sed -i "s/sf_surface_physics = 2, 2,/sf_surface_physics = 0, 0,/g" ${run_dir}/namelist.input
mpirun -np 10 ${run_dir}/real.exe >& ${run_dir}/real.log
#grep -ir 'num_metgrid_soil_levels'  ${run_dir}/namelist.input
#grep -ir 'sf_surface_physics'  ${run_dir}/namelist.input
endif
wait

if(! -f ${run_dir}/wrfinput_d01 || ! -f ${run_dir}/wrfinput_d02 || ! -f ${run_dir}/wrfbdy_d01 )then
sleep 30
cp ${run_dir}/namelist ${run_dir}/namelist.input
# Assume no met land files and land physics is 0
sed -i "s/num_metgrid_soil_levels = 4,/num_metgrid_soil_levels = 0,/g" ${run_dir}/namelist.input
sed -i "s/sf_surface_physics = 2, 2,/sf_surface_physics = 0, 0,/g" ${run_dir}/namelist.input
#grep -ir 'num_metgrid_soil_levels'  ${run_dir}/namelist.input
#grep -ir 'sf_surface_physics'  ${run_dir}/namelist.input
mpirun -np 10 ${run_dir}/real.exe >& ${run_dir}/real.log 
endif
wait

# final check again
if(-f ${run_dir}/FAIL_${nowdate}_log || -f ${run_dir}/SUCCESS_${nowdate}_log)then
rm {run_dir}/*_log
endif

if(-f ${run_dir}/wrfinput_d01 && -f ${run_dir}/wrfinput_d02 && -f ${run_dir}/wrfbdy_d01)then
#touch ${run_dir}/SUCCESS_${nowdate}_log
grep -ir 'sf_surface_physics' ${run_dir}/namelist.input >> SUCCESS_${nowdate}_log
grep -ir 'num_metgrid_soil_levels' ${run_dir}/namelist.input >> SUCCESS_${nowdate}_log
else
touch ${run_dir}/FAIL_${nowdate}_log
tail -n 10 ${run_dir}/rsl.error.0000 >& ${run_dir}/FAIL_${nowdate}_log
endif
wait
