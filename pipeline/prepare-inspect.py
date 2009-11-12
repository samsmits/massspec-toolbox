#!/usr/bin/python
import os 
import sys
import stat
import massspec_toolbox_config as conf

(db_name, filename_fasta) = conf.get_dbinfo()


filename_run = 'run-inspect.sh'
filename_pvalue = 'run-inspect-Pvalue.sh'

inspect_basedir = conf.get_inspect_path('')
current_dirname = os.getcwd()

f_run = open(filename_run,'w')
f_run.write("#!/bin/bash\n")
f_pvalue = open(filename_pvalue,'w')
f_pvalue.write("#!/bin/bash\n")
f_pvalue.write("cd %s\n"%inspect_basedir)

for filename_mzXML in os.listdir('mzXML'):
    if( not filename_mzXML.endswith('mzXML') ):
        sys.stderr.write("Skip %s ... "%filename_mzXML)
        continue
    filename_mzXML_abs = os.path.join(current_dirname,'mzXML',filename_mzXML)
    filename_base = filename_mzXML.replace('.mzXML','')
    filename_in = "%s.%s.inspect_in"%(filename_base,db_name)
    filename_in_abs = os.path.join(current_dirname,'inspect',filename_in)
    filename_out = "%s.%s.inspect_out"%(filename_base,db_name)
    filename_out_abs = os.path.join(current_dirname,'inspect',filename_out)
    filename_p = "%s.%s.inspect_pvalue"%(filename_base,db_name)
    filename_p_abs = os.path.join(current_dirname,'inspect',filename_p)

    f_inspect = open(filename_in_abs,'w')
    f_inspect.write('spectra,%s\n'%filename_mzXML_abs)
    f_inspect.write('instrument,ESI-ION-TRAP\n')
    f_inspect.write('protease,Trypsin\n')
    db_trie = os.path.join(os.path.realpath('DB'),db_name+'RS.trie')
    f_inspect.write('DB,%s\n'%db_trie)
    f_inspect.write('TagCount,50\n')
    f_inspect.write('PMTolerance,2.5\n')
    f_inspect.write('mod,57,C,fix\n')
    f_inspect.close()

    inspect_bin = conf.get_inspect_path('inspect')
    f_run.write("%s -r %s -i %s -o %s\n"%(inspect_bin,inspect_basedir,filename_in_abs,filename_out_abs))
    f_pvalue.write("python Pvalue.py -r %s -w %s -S 0.5\n"%(filename_out_abs,filename_p_abs))

f_run.close()
f_pvalue.write("cd %s\n"%current_dirname)
f_pvalue.close()

os.chmod(filename_run,stat.S_IRWXU)
os.chmod(filename_pvalue,stat.S_IRWXU)
