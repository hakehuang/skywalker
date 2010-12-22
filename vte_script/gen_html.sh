#!/bin/sh -x

BASE=/rootfs/wb
PRJ="vte_mx50 vte_mx50_d"

for i in $PRJ
do
LTPROOT=$BASE/$i
if [ -e $LTPROOT/output/latest_test_report ] ; then
. $LTPROOT/output/latest_test_report
OUTPUT_DIRECTORY=$(basename $OUTPUT_DIRECTORY)
export OUTPUT_DIRECTORY=${LTPROOT}/output/$OUTPUT_DIRECTORY
export LOGS_DIRECTORY="${LTPROOT}/results"
export TEST_OUTPUT_DIRECTORY="${LTPROOT}/output"
export TEST_LOGS_DIRECTORY=${LTPROOT}/$TEST_LOGS_DIRECTORY
export HTMLFILE=${LTPROOT}/output/$HTMLFILE
/usr/bin/perl $LTPROOT/bin/genhtml.pl $LTPROOT/tools/html_report_header.txt test_start test_end test_output execution_status $OUTPUT_DIRECTORY  > $HTMLFILE
fi
done
