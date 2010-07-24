#!/usr/bin/python
import os 
import sys
import stat
import massspec_toolbox_config as conf

(db_name, filename_fasta) = conf.get_dbinfo()

filename_run = 'run-inspect.sh'
#filename_pvalue = 'run-inspect-PValue.sh'

inspect_basedir = conf.get_inspect_path('')
current_dirname = os.getcwd()
inspect_bin = conf.get_inspect_path('inspect')
inspect2pepxml_bin = "python "+conf.get_inspect_path('InspectToPepXML.py')
msgf_bin = 'java -Xmx1000M -jar '+conf.get_inspect_path('MSGF.jar')

f_run = open(filename_run,'w')
f_run.write("#!/bin/bash\n")
#f_pvalue = open(filename_pvalue,'w')
#f_pvalue.write("#!/bin/bash\n")
#f_pvalue.write("cd %s\n"%inspect_basedir)

for filename_mzXML in os.listdir('mzXML'):
    if( not filename_mzXML.endswith('mzXML') ):
        sys.stderr.write("Skip %s ... \n"%filename_mzXML)
        continue
    filename_mzXML_abs = os.path.join(current_dirname,'mzXML',filename_mzXML)
    filename_base = filename_mzXML.replace('.mzXML','')
    filename_in = "%s.%s.inspect_in"%(filename_base,db_name)
    filename_in_abs = os.path.join(current_dirname,'inspect',filename_in)
    filename_out = "%s.%s.inspect_out"%(filename_base,db_name)
    filename_out_abs = os.path.join(current_dirname,'inspect',filename_out)
    filename_p = "%s.%s.inspect_pvalue"%(filename_base,db_name)
    filename_p_abs = os.path.join(current_dirname,'inspect',filename_p)
    filename_pepxml = "%s.%s.inspect.pepXML"%(filename_base,db_name)
    filename_pepxml_abs = os.path.join(current_dirname,'inspect',filename_pepxml)
    filename_msgf_out = "%s.%s.inspect_msgf_out"%(filename_base,db_name)
    filename_msgf_out_abs = os.path.join(current_dirname,'inspect',filename_msgf_out)
    filename_msgf_pepxml = "%s.%s.inspect_msgf.pepXML"%(filename_base,db_name)
    filename_msgf_pepxml_abs = os.path.join(current_dirname,'inspect',filename_msgf_pepxml)

    dirname_mzxml_abs = os.path.join(current_dirname,'mzXML')

    f_inspect = open(filename_in_abs,'w')
    f_inspect.write('spectra,%s\n'%filename_mzXML_abs)
    f_inspect.write('instrument,ESI-ION-TRAP\n')
    f_inspect.write('protease,Trypsin\n')
    db_trie = os.path.join(os.path.realpath('DB'),db_name+'.trie')
    f_inspect.write('DB,%s\n'%db_trie)
    f_inspect.write('TagCount,50\n')
    f_inspect.write('PMTolerance,2.5\n')
    f_inspect.write('mod,57,C,fix\n')
    f_inspect.close()

    f_run.write("%s -r %s -i %s -o %s\n"%(inspect_bin,inspect_basedir,filename_in_abs,filename_out_abs))
    f_run.write("%s -i %s -o %s -p %s -m %s -d 3\n"%(inspect2pepxml_bin, filename_out_abs,filename_pepxml_abs,filename_in_abs,dirname_mzxml_abs))
    f_run.write("%s -i %s -d %s -o %s\n"%(msgf_bin, filename_out_abs, dirname_mzxml_abs, filename_msgf_out_abs))
    f_run.write("%s -i %s -o %s -p %s -m %s -d 3\n"%(inspect2pepxml_bin, filename_msgf_out_abs,filename_msgf_pepxml_abs,filename_in_abs,dirname_mzxml_abs))

    #f_pvalue.write("python PValue.py -r %s -w %s -S 0.5\n"%(filename_out_abs,filename_p_abs))

f_run.close()
#f_pvalue.write("cd %s\n"%current_dirname)
#f_pvalue.close()

os.chmod(filename_run,stat.S_IRWXU)
#os.chmod(filename_pvalue,stat.S_IRWXU)
