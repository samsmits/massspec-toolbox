#!/usr/bin/python
import sys
import os

from MzXML import MzXML

usage_mesg = 'Usage: mzxml2precursor_list.py <mzXML file>'

if( len(sys.argv) != 2 ):
    print usage_mesg
    sys.exit(1)

def check_file(filename):
    if( not os.access(filename,os.R_OK) ):
        print "%s is not accessible."%filename
        print usage_mesg
        sys.exit(1)

filename_mzXML = sys.argv[1]
check_file(filename_mzXML)

ms1_mz2i = dict()
mzXML = MzXML()
mzXML.parse_file(filename_mzXML)

f_out = open(filename_mzXML+'.precursor_list','w')
f_out.write("#Scan_ID\tPrecursor_Mz\tPrecursor_Intensity\tRetentionTime\n")
for tmp_ms2 in mzXML.MS2_list:
    scan_id = tmp_ms2.id
    #print scan_id,tmp_ms2.precursor_intensity, tmp_ms2.precursor_mz
    f_out.write("%d\t%.5f\t%.2f\t%.3f\n"%(scan_id,tmp_ms2.precursor_mz,tmp_ms2.precursor_intensity,tmp_ms2.retention_time))
f_out.close()
