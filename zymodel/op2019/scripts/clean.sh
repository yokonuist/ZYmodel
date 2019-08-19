#!/usr/bin/csh -f
/opt/tsce/torque6/bin/qstat > check
set num = `wc -l ./check | awk '{printf($1)}' `
@ jobnum = $num - 2
echo $jobnum ok

@ i = 1
@ j = 0

while($i <= ${jobnum})
@ j = $i + 2
# Chell not allow cycle arrayset 
#echo `cat check | sed -n ''${j}','${j}'p' | awk '{printf("%7i\n",$1)}' `
set jobid = `cat check | sed -n ''${j}','${j}'p' | awk '{printf("%7i",$1)}'`
#echo $jobid
#echo `cat check | sed -n ''${j}','${j}'p' | awk '{printf("%7s\n",$2)}' `
set jobname = `cat check | sed -n ''${j}','${j}'p' | awk '{printf("%7s\n",$2)}' `
#echo $jobname
#exit

if($jobname == ZYMsys)then
echo $jobname checked
else
/opt/tsce/torque6/bin/qdel $jobid
/opt/tsce/torque6/bin/qdel $jobid
endif

@ i = $i + 1
end

rm check

exit 
