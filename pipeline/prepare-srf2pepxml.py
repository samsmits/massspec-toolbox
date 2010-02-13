#!/usr/bin/python
import os
import sys
import stat
import massspec_toolbox_config as conf

(db_name, filename_fasta) = conf.get_dbinfo()
filename_script = 'run-srf2pepxml.sh'
dirname_output = 'sequest.pepxml'

f_script = open(filename_script,'w')
f_script.write("#!/bin/bash\n")

for filename_srf in os.listdir('./SRF'):
    filename_srf = filename_srf.strip()
    if( not filename_srf.endswith('.srf') ):
        continue
    filename_old_pepxml = os.path.join(dirname_output,filename_srf.replace('.srf','')+'.xml')
    filename_new_pepxml = os.path.join(dirname_output,filename_old_pepxml.replace('.xml','')+'.sequest.pepxml')
    sys.stderr.write("Process %s ... \n"%filename_srf)
    f_script.write('echo "processing %s ..."\n'%filename_srf)
    f_script.write('bioworks_to_pepxml.rb --dbpath %s --outdir %s %s\n'%(filename_fasta,dirname_output,os.path.join('SRF',filename_srf)))
    f_script.write('mv %s %s\n'%(filename_old_pepxml,filename_new_pepxml))
f_script.close()
os.chmod(filename_script,stat.S_IRWXU)
