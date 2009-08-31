#!/usr/bin/python
import sys
import os

from marcottelab.MSScan import MS1Scan, MS2Scan
from marcottelab.mzxml import MzXML

usage_mesg = 'mzxml-to-mzsql.py <mzXML file>'
if( len(sys.argv) != 2 ):
    print usage_mesg
    sys.exit(1)

filename_mzXML = sys.argv[1]
if( not os.access(filename_mzXML,os.R_OK) ):
    print "%s is not accessible."%filename_mzXML
    print usage_mesg
    sys.exit(1)

mzXML = MzXML()
mzXML.parse_file(filename_mzXML)
for tmp_ms1 in mzXML.MS1_list:
    print "Level1",tmp_ms1.id,tmp_ms1.list_size,tmp_ms1.retention_time,tmp_ms1.peak_count

for tmp_ms2 in mzXML.MS2_list:
    print "Level2",tmp_ms2.id,tmp_ms2.ms1_id, tmp_ms2.list_size, tmp_ms2.retention_time, tmp_ms2.precursor_mz, tmp_ms2.precursor_charge
