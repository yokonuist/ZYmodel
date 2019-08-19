#!/usr/bin/csh
set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs
#source $envdir/envzymodels

# get input time from real time of os
set ds  = `date -d '12 hour ago' +%Y%m%d`
set hh  = `date +%H`

if($hh >= 0 && $hh <= 12)then
set hs  = "12"
else
set hs  = "00"
endif

set sttime = $ds$hs
set edtime = `${wrfworkdir}/bin/datetime.exe $ds$hs 4d`

echo $sttime $edtime
#exit

mkdir -p ${logdir}/$sttime

${scriptdir}/ecwps.csh $sttime $edtime >& ${logdir}/$sttime/bg_$sttime.log


${scriptdir}/ecwrf.csh $sttime $edtime >& ${logdir}/$sttime/wrf_$sttime.log

${scriptdir}/ecpost.csh $sttime $edtime >& ${logdir}/$sttime/post_$sttime.log

#update dirs for remote service

cp -rf ${diagdir}/* /public/home/henanqx/MDT/ftpdata/diag/
exit 0
