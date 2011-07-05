##/bin/sh

PLATFORM=$2

path=$3

list=$(ls ${1}/*.failed -lrt | awk '{print $8}')


tofile()
{
 echo $1 >> ${path}/${PLATFORM}_failed_status.xml		
}

create_file()
{
echo $1 > ${path}/${PLATFORM}_failed_status.xml	
}

create_file "<?xml version=\"1.0\" encoding='UTF-8'?>"
tofile "<?xml-stylesheet type=\"text/xsl\" href=\"fails.xsl\"?>"
tofile "<LOG>"
tofile "<title>"
tofile "$2"
tofile "</title>"
tofile "<total>"
tofile $(ls ${1}/*.failed | wc -l)
tofile "</total>"
for i in $list
do
#get date
idate=$(ls -lt $i | awk '{print $6}')
idate=$(echo $idate| sed 's/-//g')
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
tofile  "</fail_count>"
done
tofile "</LOG>"

