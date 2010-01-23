#!/usr/bin/python
import sys
import os

#from MSScan import MS1Scan, MS2Scan
from MzXML import MzXML

usage_mesg = 'mzxml2ms1.py <mzXML file>'

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

sys.stderr.write("Write %s.ms1 ... "%filename_mzXML)
f_out = open(filename_mzXML+'.ms1','w')
for tmp_ms1 in mzXML.MS1_list:
    f_out.write("S\t%06d\t%06d\n"%(tmp_ms1.id, tmp_ms1.id))
    f_out.write("I\tRetTime\t%.2f\n"%(tmp_ms1.retention_time))
    for i in range(0,len(tmp_ms1.mz_list)):
        f_out.write("%f\t%.2f\t0\n"%(tmp_ms1.mz_list[i],tmp_ms1.intensity_list[i]))
f_out.close()
sys.stderr.write("Done\n")
