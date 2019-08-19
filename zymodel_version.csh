#!/usr/bin/csh -f
set envdir     = /home/henanqx/MDT/Guoyk/op2019/env
source $envdir/envzydirs

# keep script dir
# bin dir

mkdir -p ./zymodel/op2019

#main routines
mkdir -p ./zymodel/op2019/scripts/
cp -rf $scriptdir/* ./zymodel/op2019/scripts/

#main envs
mkdir -p ./zymodel/op2019/env/
cp -rf $envdir/* ./zymodel/op2019/env/

#wps dir
mkdir -p ./zymodel/op2019/wps/op/bin
cp -rf $wpsworkdir/bin/*.csh ./zymodel/op2019/wps/op/bin

#wrf dir
mkdir -p ./zymodel/op2019/wrf/op/bin
cp -rf $wrfworkdir/bin/*.csh ./zymodel/op2019/wrf/op/bin
cp -rf $wrfworkdir/bin/*.pbs ./zymodel/op2019/wrf/op/bin

#dac dir
mkdir -p ./zymodel/op2019/da/op/bin
cp -rf $dacworkdir/bin/*.csh ./zymodel/op2019/da/op/bin

#output dir
mkdir -p ./zymodel/op2019/output/proc/op/bin
cp -rf $outputworkdir/bin/*.csh ./zymodel/op2019/output/proc/op/bin
cp -rf $outputworkdir/bin/src ./zymodel/op2019/output/proc/op/bin

set versions = `date +%Y%m%d%H`
echo "update to local files" >> ./zymodel/version.md
echo "Local time: " $versions >> ./zymodel/version.md
 
