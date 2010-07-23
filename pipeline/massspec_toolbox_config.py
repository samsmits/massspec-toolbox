import os

toolbox_home = '/home/taejoon/massspec-toolbox/'
path_formatdb = '/usr/bin/formatdb'
tandem_basedir = '/home/taejoon/MS.project/bin64/'
inspect_basedir = '/home/taejoon/src/inspect/'
crux_basedir = '/home/taejoon/MS.project/bin64/'
omssa_basedir = '/usr/local/src/omssa-2.1.4.linux/'
TPP_basedir = '/usr/local/src/TPP-4.3.0/'
TPP_bindir = '/usr/local/src/TPP-4.3.0/bin/'

def get_conf():
    f_conf = open('CONF','r')
    rv = dict()
    for line in f_conf:
        tokens = line.strip().split()
        rv[tokens[0]] = tokens[1]
    f_conf.close()
    return rv

def get_dbinfo():
    rv_conf = get_conf()
    db_name = rv_conf['DB_NAME']
    filename_fasta = rv_conf['DB_FILE']
    return db_name, filename_fasta

def get_TPP_path(filename):
    return os.path.join(TPP_bindir,filename)

def get_tandem_path(filename):
    if( filename == 'tandem-input' ):
        return os.path.join(toolbox_home,'config','tandem-isb_input_native.xml')
    elif( filename == 'tandem-input_k' ):
        return os.path.join(toolbox_home,'config','tandem-isb_input_kscore.xml')
    return os.path.join(tandem_basedir,filename)

def write_tandem_taxonomy(dirname_output,db_name,filename_fasta):
    filename_tax = os.path.join(dirname_output,'taxonomy.xml')
    f_tax = open(filename_tax,'w')
    f_tax.write('<?xml version="1.0"?>\n')
    f_tax.write('<bioml label="x! taxon-to-file matching list">\n')
    f_tax.write(' <taxon label="%s">\n'%db_name)
    f_tax.write('  <file format="peptide" URL="%s.pro" />\n'%filename_fasta)
    f_tax.write(' </taxon>\n')
    f_tax.write('</bioml>\n')

def get_inspect_path(filename):
    return os.path.join(inspect_basedir,filename)

def get_crux_path(filename):
    return os.path.join(crux_basedir,filename)

## OMSSA
def get_omssa_path(filename):
    if( filename == 'omssa-mods' ):
        return os.path.join(toolbox_home,'config','omssa-mods.xml')
    elif( filename == 'formatdb' ):
        return path_formatdb
    return os.path.join(omssa_basedir,filename)

## APEX
def get_TPP2APEX_parser():
    return os.path.join(toolbox_home,'APEX','np_parse_ProteinProphet.pl')
