#!/usr/bin/python
import os
import sys
import stat
import massspec_toolbox_config as conf

(db_name, filename_fasta) = conf.get_dbinfo()
current_dirname = os.getcwd()

tandem_bin = conf.get_tandem_path('tandem.exe')
filename_input = conf.get_tandem_path('tandem-input_k')
filename_fasta_pro = filename_fasta+'.pro'

filename_param_abs = '/home/taejoon/massspec-toolbox/config/tandem-isb_input_native.xml'

def tandem_taxonomy_xml(dbname=None, fasta_pro=None):
    xml_list = []
    xml_list.append('<?xml version="1.0"?>')
    xml_list.append('  <bioml label="x! taxon-to-file matching list">')
    xml_list.append('  <taxon label="%s">'%(dbname))
    xml_list.append('  <file format="peptide" URL="%s" />'%(fasta_pro))
    xml_list.append('  </taxon>')
    xml_list.append('</bioml>')

    return '\n'.join(xml_list)

def tandem_config_xml(param=None, mzxml=None, output=None, log='', seq='', taxonomy=None, dbname=None):
    xml_list = []
    xml_list.append('<?xml version="1.0" encoding="UTF-8"?>\n<bioml>')
    xml_list.append('<note type="input" label="list path, default parameters">%s</note>'%param)
    xml_list.append('<note type="input" label="spectrum, path">%s</note>'%mzxml)
    xml_list.append('<note type="input" label="output, path">%s</note>'%output)
    xml_list.append('<note type="input" label="output, log path">%s</note>'%log)
    xml_list.append('<note type="input" label="output, sequence path">%s</note>'%seq)
    xml_list.append('<note type="input" label="list path, taxonomy information">%s</note>'%taxonomy)
    xml_list.append('<note type="input" label="protein, taxon">%s</note>'%dbname)
    xml_list.append('<note type="input" label="spectrum, parent monoisotopic mass error minus">2.0</note>')
    xml_list.append('<note type="input" label="spectrum, parent monoisotopic mass error plus">4.0</note>')
    xml_list.append('<note type="input" label="spectrum, parent monoisotopic mass error units">Daltons</note>')
    xml_list.append('<note type="input" label="spectrum, parent monoisotopic mass isotope error">no</note>')
    xml_list.append('<note type="input" label="residue, modification mass">57.021464@C</note>')
    xml_list.append('<note type="input" label="protein, cleavage semi">yes</note>')
    xml_list.append('<note type="input" label="scoring, maximum missed cleavage sites">2</note>')
    xml_list.append('<note type="input" label="output, spectra">yes</note>')
    xml_list.append('</bioml>')

    return '\n'.join(xml_list)

filename_taxonomy_abs = os.path.join(current_dirname, 'tandem', 'taxonomy.xml')
f_taxonomy = open(filename_taxonomy_abs,'w')
f_taxonomy.write("%s\n"%(tandem_taxonomy_xml(fasta_pro=filename_fasta_pro,dbname=db_name)))
f_taxonomy.close()

filename_script = 'run-tandem.sh'
dirname_output = 'tandem.%s'%db_name

f_shell = open(filename_script,'w')
f_shell.write('#!/bin/bash\n')
for filename_mzxml in os.listdir('mzXML/'):
    if( not filename_mzxml.endswith('.mzXML') ):
        continue
    filename_mzxml_abs = os.path.join(current_dirname,'mzXML',filename_mzxml)
    filename_base = filename_mzxml.replace('.mzXML','')
    filename_in = filename_base+'.tandem.xml'
    filename_in_abs = os.path.join(current_dirname,'tandem',filename_in)
    filename_out = filename_base+'.tandem.out'
    filename_out_abs = os.path.join(current_dirname,'tandem',filename_out)
    filename_seq = filename_base+'.tandem.seq'
    filename_seq_abs = os.path.join(current_dirname,'tandem',filename_in)
    filename_log = filename_base+'.tandem.log'
    filename_log_abs = os.path.join(current_dirname,'tandem',filename_in)

    tandem_config = tandem_config_xml(param=filename_param_abs,mzxml=filename_mzxml_abs,\
                                output=filename_out_abs,dbname=db_name,\
                                taxonomy=filename_taxonomy_abs)
    f_in = open(filename_in_abs,'w')
    f_in.write("%s\n"%tandem_config)
    f_in.close()
    
    f_shell.write("%s %s\n"%(tandem_bin, filename_in_abs))
f_shell.close()
os.chmod(filename_script,stat.S_IRWXU)
