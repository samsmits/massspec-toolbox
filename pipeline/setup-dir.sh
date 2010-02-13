#!/bin/bash
MS_DIRS=('DB' 'RAW' 'mzXML' 'ms1' 'ms2' 'mgf' 'tmp'
         'SRF' 'sequest.pepxml' 'inspect' 'omssa' 'crux' 'tandem' 'tandem_k'
         'sequest.xinteract' 'tandem.xinteract' 'tandem_k.xinteract')

for((i=0; i<${#MS_DIRS[@]}; i++)); do
  tmp_dir=${MS_DIRS[$i]}
  if [ -d $tmp_dir ]; then
    echo "Already existss ... $tmp_dir"
  else
    echo "MAKE $tmp_dir"
    mkdir $tmp_dir
  fi
done
