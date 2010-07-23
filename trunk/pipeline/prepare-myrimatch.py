#!/usr/bin/python
import os
import sys

bin_myrimatch = '/home/taejoon/src/myrimatch/myrimatch_32-1.6.62'

filename_fasta = '/home/taejoon/MS.project/DB/UPS/UPS_combined.fasta'

param_myrimatch = '-NumChargeStates "3" -StaticMods "C 57" -OutputSuffix "-myrimatch" -CleavageRules "Trypsin/P" -NumMaxMissedCleavages "2" -UseAvgMassOfSequences "false"'

f_sh = open('run-myrimatch.sh','w')
f_sh.write('#!/bin/bash\n')
for filename in os.listdir('mzXML'):
    if( not filename.endswith('.mzXML') ):
        continue
    
    filename_mzXML = os.path.join('mzXML',filename)
    print filename_mzXML
    
    f_sh.write('%s -ProteinDatabase %s %s %s\n'%(bin_myrimatch,filename_fasta,filename_mzXML,param_myrimatch))
    filename_pepxml = filename.replace('.mzXML','-myrimatch.pepXML')
    f_sh.write('mv %s myrimatch/\n'%(filename_pepxml))
f_sh.close()
