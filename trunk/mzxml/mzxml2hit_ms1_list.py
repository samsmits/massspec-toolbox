#!/usr/bin/python
import sys
import os

from MzXML import MzXML

usage_mesg = 'mzxml2hit_ms1_list.py <mzXML file> <hit_list file>'

if( len(sys.argv) != 3 ):
    print usage_mesg
    sys.exit(1)

def check_file(filename):
    if( not os.access(filename,os.R_OK) ):
        print "%s is not accessible."%filename
        print usage_mesg
        sys.exit(1)

filename_mzXML = sys.argv[1]
filename_hit_list = sys.argv[2]
check_file(filename_mzXML)
check_file(filename_hit_list)

ms1_mz2i = dict()
mzXML = MzXML()
mzXML.parse_file(filename_mzXML)
for tmp_ms1 in mzXML.MS1_list:
    scan_id = tmp_ms1.id
    ms1_mz2i[scan_id] = dict()
    for i in range(0,len(tmp_ms1.mz_list)):
        tmp_mz = tmp_ms1.mz_list[i]
        tmp_i = tmp_ms1.intensity_list[i]
        ms1_mz2i[scan_id][tmp_mz] = tmp_i

ms2_precursor_i = dict()
for tmp_ms2 in mzXML.MS2_list:
    scan_id = tmp_ms2.id
    ms2_precursor_i[scan_id] = tmp_ms2.precursor_intensity

mz2scan = dict()
pep2scan = dict()
pep2prot = dict()
f_hit = open(filename_hit_list,'r')
for line in f_hit:
    if(line.startswith('#')):
        continue
    tokens = line.strip().split("\t")
    scan_id = tokens[0]
    charge = int(tokens[1])
    neutral_mass = float(tokens[2])
    mz = float("%.4f"%(neutral_mass/charge))
    peptide_seq = tokens[3]
    protein_id = tokens[4]
    if( not pep2prot.has_key(peptide_seq) ):
        pep2prot[peptide_seq] = protein_id
    elif( pep2prot[peptide_seq] != protein_id ):
        print "Different protein : %s - %s:%s"%(peptide_seq,protein_id,pep2prot[peptide_seq])

    if( not pep2scan.has_key(peptide_seq) ):
        pep2scan[peptide_seq] = dict()
    if( not pep2scan[peptide_seq].has_key(charge) ):
        pep2scan[peptide_seq][charge] = []

    if( not mz2scan.has_key(mz) ):
        mz2scan[mz] = dict()
    if( not mz2scan[mz].has_key(peptide_seq) ):
        mz2scan[mz][peptide_seq] = []
    mz2scan[mz][peptide_seq].append(scan_id)
    pep2scan[peptide_seq][charge].append({'mz':mz, 'scan_id':scan_id})
f_hit.close()

for pep in sorted(pep2scan.keys()):
    charge_list = pep2scan[pep].keys()
    ms2_scan_list = []
    for charge in charge_list:
        max_scan_id = 0
        min_scan_id = 0
        max_mz = 0
        min_mz = 0
        for tmp in pep2scan[pep][charge]:
            tmp_mz = tmp['mz']
            scan_tokens = tmp['scan_id'].split('.')
            start_scan_id = int(scan_tokens[1])
            end_scan_id = int(scan_tokens[2])
            ms2_scan_list.append(start_scan_id)
            ms2_scan_list.append(end_scan_id)

            if( min_scan_id == 0 ):
                min_scan_id = start_scan_id
            elif( min_scan_id > start_scan_id ):
                min_scan_id = start_scan_id
            if( max_scan_id < end_scan_id ):
                max_scan_id = end_scan_id
            if( min_mz == 0 ):
                min_mz = tmp_mz
            elif( min_mz > tmp_mz ):
                min_mz = tmp_mz
            if( max_mz < tmp_mz ):
                max_mz = tmp_mz

        putative_pep_list = []
        for tmp_mz in mz2scan.keys():
            if( tmp_mz >= min_mz and tmp_mz <= max_mz ):
                putative_pep_list += mz2scan[tmp_mz].keys()
        putative_pep_list = list(set(putative_pep_list))

        ms1_i_list = []
        ms2_precursor_i_list = []
        for tmp_scan_id in range(min_scan_id,max_scan_id+1):
            if( tmp_scan_id in ms2_scan_list ):
                ms2_precursor_i_list.append( ms2_precursor_i[tmp_scan_id] )                
            if( ms1_mz2i.has_key(tmp_scan_id) ):
                for tmp_mz in ms1_mz2i[tmp_scan_id].keys():
                    if( tmp_mz >= min_mz and tmp_mz <= max_mz ):
                        ms1_i_list.append( ms1_mz2i[tmp_scan_id][tmp_mz] )
        print "%s\t%s\t%d\t%d\t%d\t%d\t%.4f\t%.4f"%(pep,charge,len(pep2scan[pep][charge]),len(putative_pep_list),min_scan_id,max_scan_id,min_mz,max_mz)
        print "MS1\t",sorted(ms1_i_list)
        print "MS2_precursor\t",sorted(ms2_precursor_i_list)
