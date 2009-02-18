#!/bin/bash
MS_DIRS=('RAW' 'mzXML' 'SRF' 'ms1' 'ms2' 'sequest.pepxml' 'sequest.xinteract' 
          'inspect' 'mgf' 'omssa' 'crux'
          'tandem' 'tandem.xinteract' 'tandem_k' 'tandem_k.xinteract')

for((i=0; i<${#MS_DIRS[@]}; i++)); do
  tmp_dir=${MS_DIRS[$i]}
  if [ -d $tmp_dir ]; then
    echo "Already existss ... $tmp_dir"
  else
    echo "MAKE $tmp_dir"
    mkdir $tmp_dir
  fi
done
