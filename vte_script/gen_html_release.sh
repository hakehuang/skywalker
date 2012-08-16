#!/bin/bash -x

echo $@ >> /rootfs/wb/.log.txt

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
PCNT=14
ALL_PLAT=("IMX50RDP" "IMX50-RDP3" "IMX53LOCO" "IMX53SMD" "IMX51-BABBAGE" "IMX6-SABREAUTO" "IMX6-SABRELITE" \
"IMX6ARM2" "IMX6Q-Sabre-SD" "IMX6DL-ARM2" "IMX6DL-Sabre-SD" "IMX6Solo-SABREAUTO" "IMX6Sololite-ARM2" "IMX6SL-EVK");
VTE_PATH=("vte_IMX50RDP"  "vte_IMX50-RDP3" "vte_IMX53LOCO" "vte_IMX53SMD" "vte_IMX51-BABBAGE" \
"vte_IMX6-SABREAUTO" "vte_IMX6-SABRELITE" "vte_IMX6ARM2" "vte_IMX6Q-Sabre-SD" "vte_IMX6DL-ARM2" \
"vte_IMX6DL-Sabre-SD"  "vte_IMX6Solo-SABREAUTO" "vte_IMX6Sololite-ARM2" "vte_IMX6SL-EVK");

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
	valid=0
	log_lt=0
	tcnt=$(cat $LTPROOT/output/latest_test_report | wc -l)
	while [ $valid -eq 0 ];
	do
	 log_lt=$(expr $log_lt + 1)
	 if [ $log_lt -gt $tcnt ]; then
     exit 0
	 fi
	 log_name=$(head -$log_lt $LTPROOT/output/latest_test_report | tail -1)
	 ht=$(echo $log_name | cut -c 1)
	 if [ $ht != "#" ];then
	    valid=1
			sed -i "${log_lt}s/^/#/" $LTPROOT/output/latest_test_report
			break;
	 else
		 continue;
	 fi
	 if [ ! -e $log_name ]; then
     #no valid log
		 exit 1
	 fi
	done
	. $LTPROOT/output/$log_name
	OUTPUT_FILE=$(basename $OUTPUT_DIRECTORY)
	export OUTPUT_DIRECTORY=${LTPROOT}/output/$OUTPUT_FILE
	plan=$(echo $OUTPUT_FILE | sed "s/${i}_//" | sed "s/_log/^/" | cut -d '^' -f 1)	
	test_plan=${LTPROOT}/runtest/${plan}
    	test_result=${LTPROOT}/results/$(basename $HTMLFILE .html)${TEST_LOGS_DIRECTORY}.txt
    	test_output=$OUTPUT_DIRECTORY
    	/rootfs/wb/aResult.py $test_plan $test_result $test_output
    	sudo mv ${test_output}.html ${LTPROOT}/results/  
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
  ${BASE}/gen_fail_log.sh $LTPROOT/output/ $i ${TARGET_OUTPUT_BASE}
  result_html=$(basename $test_output).html
  result_txt=$(basename $test_result)
  output_log=$(basename $OUTPUT_DIRECTORY)
  echo "please see http://shlx12.ap.freescale.net/daily_test/${VTEPATH}/results/${result_html}" >> ${OUT_BASE}/LTP_RUN_ON-${OUTPUT_FILE}.failed
  echo "please see http://shlx12.ap.freescale.net/daily_test/${VTEPATH}/results/${result_txt}" >> ${OUT_BASE}/LTP_RUN_ON-${OUTPUT_FILE}.failed
  echo "please see http://shlx12.ap.freescale.net/daily_test/${VTEPATH}/results/${output_log}" >> ${OUT_BASE}/LTP_RUN_ON-${OUTPUT_FILE}.failed
  cat $LTPROOT/output/LTP_RUN_ON-${OUTPUT_FILE}.failed >> ${OUT_BASE}/LTP_RUN_ON-${OUTPUT_FILE}.failed
  mutt -s "mx$i ${OUTPUT_FILE} board test result" lbgtest@lists.shlx12.ap.freescale.net BSPTEST@freescale.com < ${OUT_BASE}/LTP_RUN_ON-${OUTPUT_FILE}.failed
	fi
 fi	
 pj=$(expr $pj + 1)
done
	done
