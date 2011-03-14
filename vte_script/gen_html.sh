#!/bin/bash

BASE=/rootfs/wb
TARGET_OUTPUT_BASE=${BASE}/daily_reports/skywalker

#PRJ="vte_mx50"
MAX_CASES=50
pj=0
#determinate the year and week
YEAR=$(date +%Y)
WEEK=$(date +%U)
DAY=$(date +%d)

declare -a VTE_PATH;
declare -a ALL_PLAT;

PRJ=$1

PCNT=4
ALL_PLAT=("IMX50RDP" "IMX53LOCO" "IMX53SMD" "IMX51-BABBAGE");
VTE_PATH=("vte_IMX50RDP_d" "vte_IMX53LOCO_d" "vte_IMX53SMD_d" "vte_IMX51-BABBAGE_d");

for i in $PRJ
do
 while [ $pj -lt $PCNT ];
 do
 if [ $i = ${ALL_PLAT[${pj}]} ];then
	VTEPATH=${VTE_PATH[${pj}]}
	LTPROOT=$BASE/$VTEPATH
  OUT_BASE=${TARGET_OUTPUT_BASE}/${VTEPATH}/${YEAR}/WW${WEEK}/${DAY}/
	mkdir -p $OUT_BASE
	if [ -e $LTPROOT/output/latest_test_report ] ; then
	. $LTPROOT/output/latest_test_report
	OUTPUT_FILE=$(basename $OUTPUT_DIRECTORY)
	export OUTPUT_DIRECTORY=${LTPROOT}/output/$OUTPUT_FILE
	export LOGS_DIRECTORY="${LTPROOT}/results"
	export TEST_OUTPUT_DIRECTORY="${LTPROOT}/output"
	export TEST_LOGS_DIRECTORY=${LTPROOT}/$TEST_LOGS_DIRECTORY
	export HTMLFILE=${OUT_BASE}$HTMLFILE
	#judge whether the log file is too large, if so split them
	all_end=$(grep -Rn "<<<test_end>>>" $OUTPUT_DIRECTORY)
	case_cnt=$(echo $all_end | wc -w)
	if [ $case_cnt -gt $MAX_CASES ]; then
	#log files seems too large splits them 
		icnt=0
		lcnt_start=1
		lcnt_end=1
		file_cnt=0
		max_file=$(echo "$case_cnt/$MAX_CASES" | bc)
		touch ${OUT_BASE}/$(basename ${OUTPUT_DIRECTORY})_0
		echo "" > ${OUT_BASE}/$(basename ${OUTPUT_DIRECTORY})_0
		#grep -Rn "<<<test_end>>>"  $OUTPUT_DIRECTORY | sed -n '50p' | cut -d : -f 1
		while [  $icnt -lt $case_cnt ]
		do
			#echo $LINE >> ${OUT_BASE}/$(basename ${OUTPUT_DIRECTORY})_${file_cnt}
			icnt=$(expr $icnt + $MAX_CASES)
			if [ $icnt -gt $case_cnt ]; then
           lcnt_end=$(echo $all_end | cut -d " " -f ${case_cnt} | cut -d ":" -f 1)
			else
			     lcnt_end=$(echo $all_end | cut -d " " -f $icnt | cut -d ":" -f 1)
			fi
			sed -n "${lcnt_start},${lcnt_end}p" $OUTPUT_DIRECTORY > ${OUT_BASE}/$(basename ${OUTPUT_DIRECTORY})_${file_cnt} 
		  lcnt_start=$(expr $lcnt_end + 1)
			oHTMLFILE=$(basename $HTMLFILE .html)_${file_cnt}.html
			echo "output to ${OUT_BASE}/$oHTMLFILE"
			/usr/bin/perl $LTPROOT/bin/genhtml.pl $LTPROOT/tools/html_report_header.txt \
			test_start test_end test_output execution_status ${OUT_BASE}/$(basename ${OUTPUT_DIRECTORY})_${file_cnt}  > ${OUT_BASE}/${oHTMLFILE}
      file_cnt=$(expr $file_cnt + 1)
			touch ${OUT_BASE}/$(basename ${OUTPUT_DIRECTORY})_${file_cnt}
			echo "" > ${OUT_BASE}/$(basename ${OUTPUT_DIRECTORY})_${file_cnt}
		 done
		else
		/usr/bin/perl $LTPROOT/bin/genhtml.pl $LTPROOT/tools/html_report_header.txt test_start test_end test_output execution_status $OUTPUT_DIRECTORY  > $HTMLFILE
		fi
  sort $LTPROOT/output/LTP_RUN_ON-${OUTPUT_FILE}.failed | uniq > ${OUT_BASE}/LTP_RUN_ON-${OUTPUT_FILE}.failed	
  echo "see http://shlx12.ap.freescale.net/test_reports/daily_reports/skywalker/${VTEPATH}/${YEAR}/WW${WEEK}/${DAY}" \
  | mutt -s "mx$i daily test finished" lbgtest@lists.shlx12.ap.freescale.net BSPTEST@freescale.com
	fi
 fi	
 pj=$(expr $pj + 1)
done
	done
