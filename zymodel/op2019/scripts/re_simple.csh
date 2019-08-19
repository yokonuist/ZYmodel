#!/usr/bin/csh -f
set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs
#source $envdir/envzymodels

# get input time from real time of os
#set ds  = `date -d '12 hour ago' +%Y%m%d`
#set hh  = `date +%H`

#if($hh >= 0 && $hh <= 12)then
#set hs  = "12"
#else
#set hs  = "00"
#endif

set sttime = $1
set edtime = `${wrfworkdir}/bin/datetime.exe $sttime 4d`

#echo $sttime $edtime
#exit

${scriptdir}/ecwps.csh $sttime $edtime >& ${henanldir}/bg_$sttime.log


${scriptdir}/ecwrf.csh $sttime $edtime >& ${henanldir}/wrf_$sttime.log

#${scriptdir}/ecpost.csh $sttime $edtime >& ${henanldir}/post_$sttime.log

exit 
