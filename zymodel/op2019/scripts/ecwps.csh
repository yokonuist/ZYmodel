#!/usr/bin/csh -f

# This Script doesnot support backnod -------------------
# which means please donot use "&" when call this scripts
#  Edited by Guoyk. 2019.8.10
#  e.g.>  $0 2019080900 2019081300 >& wps.log 

set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs
#source $envdir/envzymodels 

set nowdate    = $1
set enddate    = $2

set workdir    = ${wpsworkdir}
set rawdir_ec  = /public/home/henanqx/MDT/ftpdata/.ecdata2019
set rawdir_gfs = /home/henanqx/MDT/Guoyk/op2019/gfs
set Tooldir    = ${workdir}/bin

cd ${workdir}

#---- Note SUCCESS File First
if(-f ${wpsdir}/SUCCESS_merge0 || -f ${wpsdir}/SUCCESS_merge2 || -f ${wpsdir}/SUCCESS_merge3 )then
rm ${wpsdir}/SUCCESS*
endif

rm -rf ${workdir}/working
mkdir -p ${workdir}/working
cd ${workdir}/working

ln -fs ${Tooldir}/*.exe ${workdir}/working

cp ${Tooldir}/*.TBL ${workdir}/working
cp ${Tooldir}/namelist ${workdir}/working
cp ${Tooldir}/link_grib.csh ${workdir}/working

# define nowdate
 set yy = `echo $nowdate |cut -c 1-4`
 set mm = `echo $nowdate |cut -c 5-6`
 set ds = `echo $nowdate |cut -c 7-8`
 set hs = `echo $nowdate |cut -c 9-10`

 set ye = `echo $enddate |cut -c 1-4`
 set me = `echo $enddate |cut -c 5-6`
 set de = `echo $enddate |cut -c 7-8`
 set he = `echo $enddate |cut -c 9-10`

echo $yy$mm$ds
echo $ye$me$de

# copy ec and gfs data # handle ec raw data
cp -rf $rawdir_ec/${yy}${mm}${ds}/*C1D*${mm}${ds}${hs}*.bz2 ${workdir}/working
set fbz = (`ls -1 W_NAFP_C_ECMF*C1D*.bz2`)
set num = $#fbz
echo $num ${fbz[1]}

set j = 1 
while ( $j <= $num )
/usr/bin/bzip2 -d ${workdir}/working/${fbz[$j]} &
@ j = $j + 1
end
wait

cp $Tooldir/grib_copy ${workdir}/working
cp $Tooldir/link_grib.csh ${workdir}/working

set file=(`ls -1 W_NAFP_C_ECMF*C1D*1`)
set len=$#file

set i = 1
while($i <= $len)
#echo $i ok  $file[$i] get grib1 file
${workdir}/working/grib_copy -v -w edition=1 ${workdir}/working/${file[$i]} ${workdir}/working/${file[$i]}.grib >& ${workdir}/working/grib_copy.log &
@ i = $i + 1
end
wait

cd $workdir/working
rm $workdir/working/W_NAFP_C_ECMF*C1D*1
# GET The Running time of namelist
sed -i "s/start_date = '2019-03-27_00:00:00', '2019-03-27_00:00:00', /start_date = '${yy}-${mm}-${ds}_${hs}:00:00', '${yy}-${mm}-${ds}_${hs}:00:00',/g" $workdir/working/namelist
sed -i "s/end_date   = '2019-03-30_00:00:00', '2019-03-30_00:00:00',/end_date   = '${ye}-${me}-${de}_${he}:00:00', '${ye}-${me}-${de}_${he}:00:00',/g" $workdir/working/namelist

cp $workdir/working/namelist $workdir/working/namelist.wps

$workdir/working/geogrid.exe >& $workdir/working/geog.log

#-----------------------------------------------------------------
#    Ungrib4.1  various datasets, 2019.8.10 
# Define the core namelist-- doing ungrib and merge
# e.g.>  opt1: ec ; opt2: gfs ; opt3: merge
# Note: Ungrib and Metgrid of version 3.9wrf NOT support parallel run
#-----------------------------------------------------------------
cp -rf $rawdir_gfs/$yy$mm$ds/gfs.t${hs}z* $workdir/working
rm $workdir/working/*.tmp

cp $workdir/working/namelist $workdir/working/namelist_core0
cp $workdir/working/namelist $workdir/working/namelist_core
cd  $workdir/working

# Ungrib field by using namelist_core ----------------
cd $workdir/working
# GET ec Atmo Field
/usr/bin/csh $workdir/working/link_grib.csh $workdir/working/*.grib
cp $Tooldir/Vtable.ec $workdir/working/Vtable
cp $workdir/working/namelist $workdir/working/namelist_core
sed -i "s/prefix = 'pl',/prefix = 'pl',/g" $workdir/working/namelist_core
cp $workdir/working/namelist_core $workdir/working/namelist.wps
#mpirun -np 10 $workdir/working/ungrib.exe >& $workdir/working/ungrib.log
$workdir/working/ungrib.exe >& $workdir/working/ungrib_atmo.log
wait

# GET gfs Soil field
cp $workdir/working/namelist $workdir/working/namelist_core
sed -i "s/prefix = 'pl',/prefix = 'sl',/g" $workdir/working/namelist_core
cp $workdir/working/namelist_core $workdir/working/namelist.wps
/usr/bin/csh $workdir/working/link_grib.csh $workdir/working/gfs*
cp $Tooldir/Vtable.sl $workdir/working/Vtable
$workdir/working/ungrib4.exe >& $workdir/working/ungrib_sl.log
wait

# GET ec Sig
 /usr/bin/csh $workdir/working/link_grib.csh $workdir/working/*.grib
 cp $Tooldir/Vtable.ECMWF $workdir/working/Vtable
 cp $workdir/working/namelist $workdir/working/namelist_core
 sed -i "s/prefix = 'pl',/prefix = 'ec',/g" $workdir/working/namelist_core
 cp $workdir/working/namelist_core $workdir/working/namelist.wps
# mpirun -np 10 $workdir/working/ungrib.exe >& $workdir/working/ungrib.log
 $workdir/working/ungrib.exe >& $workdir/working/ungrib_ec.log
wait

# GET gfs Sig
 /usr/bin/csh $workdir/working/link_grib.csh $workdir/working/gfs*
 cp $Tooldir/Vtable.GFS $workdir/working/Vtable
 cp $workdir/working/namelist $workdir/working/namelist_core
 sed -i "s/prefix = 'pl',/prefix = 'gfs',/g" $workdir/working/namelist_core
 cp $workdir/working/namelist_core $workdir/working/namelist.wps
# mpirun -np 10 $workdir/working/ungrib.exe >& $workdir/working/ungrib.log
 $workdir/working/ungrib4.exe >& $workdir/working/ungrib_gfs.log
wait

# MetGrid field by using namelist_core0 ----------------
cd $workdir/working
# option0 Merging field ----------------------------------- default
mkdir -p $workdir/working/merge0
cp $workdir/working/namelist $workdir/working/namelist_core0
sed -i "s/fg_name = 'pl','sl'/fg_name = 'pl','sl'/g" $workdir/working/namelist_core0
cp $workdir/working/namelist_core0 $workdir/working/namelist.wps 
$workdir/working/metgrid.exe >& $workdir/working/metgrid_0.log
mv $workdir/working/met_em.d0* $workdir/working/merge0/
if(-f $workdir/../SUCCESS_merge0)then
rm $workdir/../SUCCESS_merge0
endif
set checknum = `ls -l $workdir/working/merge0/met_em.d0* | wc -l`
if($checknum >= 66)then
touch $workdir/../SUCCESS_merge0
endif
#---------------------------------------------------------------
wait

#option1 Merging field intense -----------------------------------
#mkdir -p $workdir/working/merge1
#cp $workdir/working/namelist $workdir/working/namelist_core0
#sed -i "s/fg_name = 'pl','sl'/fg_name = 'ec','gfs'/g" $workdir/working/namelist_core0
#cp $workdir/working/namelist_core0 $workdir/working/namelist.wps
#$workdir/working/metgrid.exe >& $workdir/working/metgrid_1.log
#mv $workdir/working/met_em.d0* $workdir/working/merge1/
#---------------------------------------------------------------

#option1 Merging field ec -----------------------------------
mkdir -p $workdir/working/merge2
cp $workdir/working/namelist $workdir/working/namelist_core0
sed -i "s/fg_name = 'pl','sl'/fg_name = 'ec',/g" $workdir/working/namelist_core0
cp $workdir/working/namelist_core0 $workdir/working/namelist.wps
$workdir/working/metgrid.exe >& $workdir/working/metgrid_2.log
mv $workdir/working/met_em.d0* $workdir/working/merge2/
if(-f $workdir/../SUCCESS_merge2)then
rm $workdir/../SUCCESS_merge2
endif
set checknum = `ls -l $workdir/working/merge2/met_em.d0* | wc -l`
if($checknum >= 66)then
touch $workdir/../SUCCESS_merge2
endif
wait
#---------------------------------------------------------------

#option1 Merging field gfs -----------------------------------
mkdir -p $workdir/working/merge3
cp $workdir/working/namelist $workdir/working/namelist_core0
sed -i "s/fg_name = 'pl','sl'/fg_name = 'gfs',/g" $workdir/working/namelist_core0
cp $workdir/working/namelist_core0 $workdir/working/namelist.wps
$workdir/working/metgrid.exe >& $workdir/working/metgrid_3.log
mv $workdir/working/met_em.d0* $workdir/working/merge3/
if(-f $workdir/../SUCCESS_merge3)then
rm $workdir/../SUCCESS_merge3
endif
set checknum = `ls -l $workdir/working/merge3/met_em.d0* | wc -l`
if($checknum >= 66)then
touch $workdir/../SUCCESS_merge3
endif
wait
#---------------------------------------------------------------

# Finish EC and GFS initialization of Step 01

echo Finish EC and GFS initialization of Step 01

exit 0


