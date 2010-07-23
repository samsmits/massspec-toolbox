#!/usr/bin/python
import os
import sys

bin_directag = '/home/taejoon/src/directag/directag'
bin_tagrecon = '/home/taejoon/src/directag/tagrecon'

filename_fasta = '/home/taejoon/MS.project/DB/UPS/UPS_combined.fasta'

param_directag = '-NumChargeStates "3" -StaticMods "C 57" -OutputSuffix "-directag"'
param_tagrecon = '-NumChargeStates "3" -StaticMods "C 57" -OutputSuffix "-tagrecon" -DecoyPrefix "xf_"'

f_sh = open('run-directag.sh','w')
f_sh.write('#!/bin/bash\n')
for filename in os.listdir('mzXML'):
    if( not filename.endswith('.mzXML') ):
        continue
    
    filename_mzXML = os.path.join('mzXML',filename)
    print filename_mzXML
    
    f_sh.write('%s %s %s\n'%(bin_directag,filename_mzXML,param_directag))
    filename_directag = filename.replace('.mzXML','-directag.tags')
    filename_pepxml = filename.replace('.mzXML','-directag-tagrecon.pepXML')
    f_sh.write('%s -ProteinDatabase %s %s %s\n'%(bin_tagrecon,filename_fasta,filename_directag,param_tagrecon))
    f_sh.write('mv %s directag/\nmv %s directag/\n'%(filename_directag,filename_pepxml))
f_sh.close()
