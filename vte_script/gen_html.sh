#!/bin/sh -x

BASE=/rootfs/wb
PRJ="vte_mx50 vte_mx50_d"
MAX_CASES=50

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
	#judge whether the log file is too large, if so split them
	case_cnt=$(cat $OUTPUT_DIRECTORY | grep -i "<<<test_start>>>" | wc -l)
	if [ $case_cnt -gt $MAX_CASES ]; then
	#log files seems too large splits them 
		case_cnt=0
		file_cnt=0
		touch ${OUTPUT_DIRECTORY}_0
		cat $OUTPUT_DIRECTORY | while read LINE
		do
			echo $LINE >> ${OUTPUT_DIRECTORY}_${file_cnt}
      taged=$(echo $LINE | grep -i "<<<test_end>>>"| wc -l)
			if [ $taged -eq 1 ]; then
			  icnt=$(expr $case_cnt + 1)
				if [ $icnt -eq $MAX_CASES ]; then
         file_cnt=$(expr $file_cnt + 1)
				 icnt=0
				 oHTMLFILE=$(basename $HTMLFILE .html)_${file_cnt}.html
				 /usr/bin/perl $LTPROOT/bin/genhtml.pl $LTPROOT/tools/html_report_header.txt \
				 test_start test_end test_output execution_status ${OUTPUT_DIRECTORY}_${file_cnt}  > $oHTMLFILE
				 touch ${OUTPUT_DIRECTORY}_${file_cnt}
				fi
			fi
		done
		/usr/bin/perl $LTPROOT/bin/genhtml.pl $LTPROOT/tools/html_report_header.txt \
		test_start test_end test_output execution_status ${OUTPUT_DIRECTORY}_${file_cnt}  > $oHTMLFILE
	else
	/usr/bin/perl $LTPROOT/bin/genhtml.pl $LTPROOT/tools/html_report_header.txt test_start test_end test_output execution_status $OUTPUT_DIRECTORY  > $HTMLFILE
	fi
fi
done
