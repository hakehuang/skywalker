bin_prog=mkimage
PERFIX=
PLATFORM="25 31 35 37 51 50 53 61"

if [ $# -lt 1 ]; then
  echo "do all platform"
  for i in $PLATFORM
  do
  if [ -e mx${i}_src.txt ]; then
   $bin_prog -A ARM -O linux -T script -C none -a 0 -e 0 -n "autoscr script" -d mx${i}_src.txt ${PERFIX}mx${i}_asrc_daily.img || return 1
  else
   echo " no source file for $i"
  fi
  done

else
  echo "do $1 only" 
  if [ -e mx${1}_src.txt ]; then
   $bin_prog -A ARM -O linux -T script -C none -a 0 -e 0 -n "autoscr script" -d mx${1}_src.txt ${PERFIX}mx${1}_asrc_daily.img || return 1
  else
   echo " no source file for $1"
  fi
fi 
