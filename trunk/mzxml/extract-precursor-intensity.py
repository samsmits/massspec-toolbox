#!/usr/bin/python
import os
import sys
import re

usage_mesg = 'Usage: extract-precursor-intensity.py <.mzXML file>'

if( len(sys.argv) != 2 ):
    print usage_mesg
    sys.exit(1)

filename_mzXML = sys.argv[1]
if( not os.access(filename_mzXML,os.R_OK) ):
    print usage_mesg
    sys.exit(1)
filename_base = os.path.basename(filename_mzXML).replace('.mzXML','')

scan_num = 0
ms_level = 0
ret_time = 0.0
re_scan_num = re.compile('<scan num="([0-9]+)"')
re_retention_time = re.compile('retentionTime="PT([0-9\.]+)S"')
re_precursor_mz = re.compile('([0-9\.e\+]+)</precursorMz>')
re_precursor_intensity = re.compile('precursorIntensity="([0-9\.e\+]+)"')
re_precursor_charge = re.compile('precursorCharge="([0-9]+)"')

f_out = open(filename_base+'.precursor_list','w')
sys.stderr.write("Write %s.precursor_list ... "%filename_base)
f_out.write("#Scan_id\tCharge\tM/z\tIntensity\tRetTime\n")
f_mzXML = open(filename_mzXML,'r')
for line in f_mzXML:
    line = line.strip()
    if( re_scan_num.search(line) >= 0 ):
        scan_num = re_scan_num.search(line).group(1)
    if( line == 'msLevel="2"' ):
        ms_level = '2'
    elif( line.find('msLevel=') >= 0 ):
        ms_level = '0'
    if( re_retention_time.search(line) >= 0 ):
        ret_time = re_retention_time.search(line).group(1)
    if( ms_level == '2' ):
        if( line.startswith('<precursorMz ') ):
            intensity = re_precursor_intensity.search(line).group(1)
            charge = re_precursor_charge.search(line).group(1)
            mz = re_precursor_mz.search(line).group(1)
            scan_id = "%s.%s.%s.%s"%(filename_base,scan_num,scan_num,charge)
            f_out.write("%s\t%s\t%s\t%s\t%s\n"%(scan_id,charge,mz,intensity,ret_time))
f_mzXML.close()
f_out.close()
sys.stderr.write("Done\n")
