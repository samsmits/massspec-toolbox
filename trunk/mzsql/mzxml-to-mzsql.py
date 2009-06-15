#!/usr/bin/python
import sys
import base64
import struct
import xml.parsers.expat

from marcottelab.MSScan import MS1Scan, MS2Scan
from marcottelab.mzxml import MzXML

filename_mzXML = 'test.mzXML'

mzXML = MzXML()
mzXML.parse_file(filename_mzXML)
for tmp_ms1 in mzXML.MS1_list:
    print "Level1",tmp_ms1.id,tmp_ms1.list_size,tmp_ms1.retention_time,tmp_ms1.peak_count

for tmp_ms2 in mzXML.MS2_list:
    print "Level2",tmp_ms2.id,tmp_ms2.ms1_id, tmp_ms2.list_size, tmp_ms2.retention_time, tmp_ms2.precursor_mz, tmp_ms2.precursor_charge
