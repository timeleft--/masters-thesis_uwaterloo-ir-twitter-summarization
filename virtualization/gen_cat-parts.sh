#!/bin/bash
if [ $# -ne 3 ]; then
  echo "usage $0 inDir outDir numFilesToCat"
  exit 1
fi
nFilesIn=`ls -1 $1 | grep part | wc -l`
#filesIn=`ls -1 $1 | grep part`
nFilesOut=`expr $nFilesIn / $3`
#echo "$nFilesIn files will be concatenated into $nFilesOut"
echo "#!/bin/bash"
for outIx in $(eval echo "{0..$nFilesOut}")
do
  #if [ outIx == 0]; then
   # nameSfx="part-m-0000"
  #el
  if [ $outIx -lt 10 ]; then
    nameSfx="part-m-000"
  elif [ $outIx -lt 100 ]; then
    nameSfx="part-m-00"
  elif [ $outIx -lt 1000 ]; then
    nameSfx="part-m-0"
  else
    nameSfx="part-m-"
  fi
 # $fileNum=`expr $outIx * 10`
  outFile="${2}/${nameSfx}0${outIx}"
  inSfx="${1}/${nameSfx}${outIx}"
  echo "cat ${inSfx}0 > ${outFile}"
  for d in {1..9}
  do
    echo "cat ${inSfx}${d} >> ${outFile}"  
  done
done

