#!/usr/bin/csh -f
set ecftp_id    = 172.18.152.9
set ecftp_usr   = getdown
set ecftp_pwd   = getdown1
set ecftp_dir   = /nafp/ecmf
set ec_localdir = /home/data/op2019/ec
set ec_opid     =  192.168.1.6
set ec_opusr    = henanqx
set ec_oppwd    = `cat ~/.ssh/henanqx_pwd | awk '{print $1}'`
set ec_opdir    = /ftpdata/.ecdata2019

set ec_scpdir   = /home/henanqx/ftpwrite/ftpdata/.ecdata2019

#rysnc date should be noted first
set rundate     = `date -d '8 hour ago' +%Y%m%d`
set deldate     = `date -d '3 days ago' +%Y%m%d`

#rysnc ftp1 to ftp2 with date
set ftp1ip  = ${ecftp_id}
set ftp1dir = ${ecftp_dir}
set ftp1usr = ${ecftp_usr}
set ftp1pwd = ${ecftp_pwd}

set ftp2ip  = ${ec_opid}  
set ftp2dir = ${ec_opdir}
set ftp2usr = ${ec_opusr}
set ftp2pwd = ${ec_oppwd}

set rundir  = ${ec_localdir}

cd $rundir
	
if(-d ${ec_localdir}/$deldate)then
rm -rf ${ec_localdir}/$deldate
endif

if(! -d ${ec_localdir}/$rundate)then
mkdir -p ${ec_localdir}/$rundate
endif

ftp -n -v $ftp1ip 21 << EOF
    user ${ftp1usr} ${ftp1pwd}
    binary
    prompt    
    cd ${ftp1dir}    
    nlist W_NAFP_C_ECMF_${rundate}*C1D*.bz2 ${ec_localdir}/ftp1.log  
    close
    bye
EOF

# since henanqx NOT SUPPORT ftp
#    We use sftp to replace
# --------------------------- 2019.8.19    

#ftp -n -v $ftp2ip 21 <<EOF
#    user ${ftp2usr} ${ftp2pwd}
#    binary
#    mkdir ${ftp2dir}/${rundate}   
#    cd ${ftp2dir}
#    cd ${rundate}
#    lcd ${ec_localdir}
#    prompt   
#    nlist W_NAFP_C_ECMF_${rundate}* ${ec_localdir}/ftp2.log  
#    close
#    bye
#EOF

#-----optional choice, diff file was only choiced by local
cd ${ec_localdir}/$rundate
ls -1 W_NAFP_C_ECMF_${rundate}* >& ${ec_localdir}/ftp2.log
#----- 

# compare two dir files and rysnc
grep -vFf ${ec_localdir}/ftp2.log ${ec_localdir}/ftp1.log >& ${ec_localdir}/diff.log

set file=(`cat ${ec_localdir}/diff.log`)
set len=$#file

echo $len
if($len < 1)then
echo "Nothing to do"
else
echo "Begin transfer files by using SFTP"

set i = 1
while($i <= $len)
  echo $i ${file[1]}
 #download ftp file to local dir
ftp -n<<EOF
open ${ftp1ip}
user ${ftp1usr} ${ftp1pwd}
binary
cd ${ftp1dir}
lcd ${ec_localdir}/${rundate} 
get ${file[$i]} ${file[$i]}
close
bye
EOF


 # pass local file to sftp
 # nopass https://blog.csdn.net/yangshangwei/article/details/53024203
 # bugs: remote dirs cannot be fiexed #put ${file[$i]}
 # only create dirs ;#Just use scp from shell command
 
sftp ${ftp2usr}@${ftp2ip} << EOF
mkdir ${ec_scpdir}/${rundate}  
cd ${ftp2dir}/${rundate}
lcd ${ec_localdir}/${rundate}
! scp ${ec_localdir}/${rundate}/${file[$i]} ${ftp2usr}@${ftp2ip}:${ec_scpdir}/${rundate}
quit
EOF

  

@ i = $i + 1
end

endif 



exit
