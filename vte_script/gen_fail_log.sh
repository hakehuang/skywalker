#!/bin/sh -x
# ./gen_fail_log.sh /home/smb/nfs/wb/vte_IMX50-RDP3_d/output IMX50-RDP3 .
#<output fail log path> <platfrom name> <output path>
echo $* >> /rootfs/wb/.log.txt

PLATFORM=$2

path=$3

#list=$(ls ${1}/*.failed -lrt | awk '{print $8}')

for i in $(ls ${1}/*.failed -lrt)
do
file=$(echo $i | grep "failed" | wc -l)
if [ $file -gt 0 ] ; then
list=$(echo $list $i)
fi
done

MAXcase=300

tofile()
{
 echo $1 >> ${path}/${PLATFORM}_failed_status.xml		
}

create_file()
{
echo $1 > ${path}/${PLATFORM}_failed_status.xml	
}
for i in $list
do
runfile_a=$(basename $i | sed 's/LTP_RUN_ON-//' | sed 's/_log/#/' | cut -d '#' -f 1)
runfile=$(echo $runfile_a | sed 's/_/#/' | cut -d '#' -f 2)
totalcase_path=$(dirname $(dirname $i))/runtest/
total_case=$(cat ${totalcase_path}${runfile} | grep -v '#' | wc -l)
if [ $total_case -gt 0  ]; then
MAXcase=$total_case
fi
done

create_file "<?xml version=\"1.0\" encoding='UTF-8'?>"
tofile "<?xml-stylesheet type=\"text/xsl\" href=\"fails.xsl\"?>"
tofile "<LOG>"
tofile "<title>"
tofile "$2"
tofile "</title>"
tofile "<total>"
tofile $(ls ${1}/*.failed | wc -l)
tofile "</total>"
tofile "<maxcase>"
tofile $MAXcase
tofile "</maxcase>"

for i in $list
do
#get date
idate=$(stat -c %y $i | awk '{print $1}')
idate=$(echo $idate| sed 's/-//g')
runfile_a=$(basename $i | sed 's/LTP_RUN_ON-//' | sed 's/_log/#/' | cut -d '#' -f 1)
runfile=$(echo $runfile_a | sed 's/_/#/' | cut -d '#' -f 2)
mac=$(basename $i | sed 's/LTP_RUN_ON-//' | sed 's/_log/#/' | cut -d '#' -f 2 | sed 's/failed/txt/')
resultpath=$(dirname $(dirname $i))/results/
resultfile=$(ls $resultpath | grep $runfile | grep $mac | grep $idate)
if [ ! -z "$resultfile" ]; then
total_case=$(cat ${resultpath}${resultfile} | grep "Tatal Tests:" | awk '{print $3}')
else
total_case=$MAXcase
fi
tofile "<fail_count>"
tofile "<count>"
tofile  $(cat $i | wc -l)
tofile  "</count>"
tofile  "<flink>"
tofile  "http://shlx12.ap.freescale.net/test_reports/${2}_output/$(basename $i)"
tofile  "</flink>"
tofile  "<fdate>"
tofile  $idate
tofile  "</fdate>"
tofile  "<total_cases>"
tofile  ${total_case}
tofile  "</total_cases>"
tofile  "<runfile>"
tofile  "http://shlx12.ap.freescale.net/test_reports/runtest/${runfile}"
tofile  "</runfile>"
tofile  "</fail_count>"
done
tofile "</LOG>"

