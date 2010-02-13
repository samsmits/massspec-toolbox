#!/usr/bin/python 
import os
import sys
import stat
import massspec_toolbox_config as conf

path_xinteract = conf.get_TPP_path('xinteract')
path_APEX_parser = conf.get_TPP2APEX_parser()
TPP_cutoff = 0.05

filename_script = 'run-sequest.xinteract-combined.sh';
f_script = open(filename_script,'w')
f_script.write('#!/bin/bash\n')
f_script.write('SAMPLE_NAME="tmp"\n')

for filename_pepxml in os.listdir('sequest.pepxml'):
    filename_pepxml = filename_pepxml.strip()
    if( not filename_pepxml.endswith('.sequest.pepxml') ):
        continue
    
    filename_base = filename_pepxml.replace('.pepxml','')
    filename_pepxml = os.path.join('sequest.pepxml',filename_pepxml)

    f_script.write('cp %s %s\n'%(filename_pepxml,'tmp/'))

filename_base = os.path.join('sequest.xinteract','$SAMPLE_NAME')
filename_xinteract = filename_base+'.xinteract.xml'
filename_prot = filename_base+'.xinteract.prot.xml'
filename_summary = filename_base+'.xinteract.summary'
f_script.write("%s -N%s -Op tmp/*.pepxml\n"%(path_xinteract,filename_xinteract))
f_script.write("%s %s %.2f %s\n"%(path_APEX_parser,filename_prot,TPP_cutoff,filename_summary))

f_script.write('rm -f tmp/*')
f_script.close()
os.chmod(filename_script,stat.S_IRWXU)
