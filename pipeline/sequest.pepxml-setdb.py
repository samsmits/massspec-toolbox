#!/usr/bin/python
import os
import sys
import massspec_toolbox_config as conf

(db_name, filename_fasta) = conf.get_dbinfo()
sys.stderr.write("Use %s as DB file\n"%filename_fasta)

for filename_pepxml in os.listdir('sequest.pepxml/'):
    if( not filename_pepxml.endswith('.pepxml') ):
        continue
    filename_pepxml = os.path.join('sequest.pepxml',filename_pepxml)
    filename_pepxml_tmp = filename_pepxml+'.tmp'
    f_tmp = open(filename_pepxml_tmp,'w')
    f_pepxml = open(filename_pepxml,'r')
    for line in f_pepxml:
        line = line.strip()
        if( line.startswith('<search_database local_path="') ):
            f_tmp.write('<search_database local_path="%s" type="AA"/>\n'%filename_fasta)
        elif( line.startswith('<parameter name="list path, sequence source #1" value"') ):
            f_tmp.write('<parameter name="list path, sequence source #1" value="%s"/>\n'%filename_fasta)
        elif( line.startswith('<parameter name="first_database_name" value"') ):
            f_tmp.write('<parameter name="first_database_name" value="%s"/>\n'%filename_fasta)
        else:
            f_tmp.write('%s\n'%line)
    f_pepxml.close()
    f_tmp.close()
    os.rename(filename_pepxml_tmp,filename_pepxml)
