#!/bin/bash

MS_DIRS=('RAW' 'mzXML' 'SRF' 'sequest.pepxml' 'sequest.xinteract' \
          'inspect' 'inspect.PValue' 'mgf' 'omssa'
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
