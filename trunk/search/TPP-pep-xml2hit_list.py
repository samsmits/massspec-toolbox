#!/usr/bin/python
import os
import sys
import re
import pepxml

usage_mesg = 'Usage: TPP-pep-xml2hit_list.py <PeptideProphet .xml file>'

if( len(sys.argv) != 2 ):
    print usage_mesg
    sys.exit(1)

filename_pepxml = sys.argv[1]
if( not os.access(filename_pepxml,os.R_OK) ):
    print "%s is not accessible."%filename_pepxml
    print usage_mesg
    sys.exit(1)

PSM = pepxml.parse_by_filename(filename_pepxml)

filename_out = filename_pepxml.replace('.pepxml','').replace('.xml','')+'.hit_list'
sys.stderr.write("Write %s ... \n"%filename_out)
f_out = open(filename_out,'w')
f_out.write("# pepxml: %s\n"%filename_pepxml)
f_out.write("#Spectrum_id\tCharge\tNeutralMass\tPeptide\tProtein\tMissedCleavages\tAbsScore(Xcorr)\tRelScore(DeltaCn)\tProbability\n")
f_out95 = open(filename_out+"_P095",'w')
f_out95.write("# pepxml: %s\n"%filename_pepxml)
f_out95.write("#Spectrum_id\tCharge\tNeutralMass\tPeptide\tProtein\tMissedCleavages\tAbsScore(Xcorr)\tRelScore(DeltaCn)\tProbability\n")
for spectrum_id in PSM.keys():
    charge = PSM[spectrum_id]['charge']
    neutral_mass = PSM[spectrum_id]['neutral_mass']
    best_peptide = ''
    best_protein = ''
    best_xcorr = 0
    missed_cleavages = 0
    best_prob = 0
    for tmp_hit in PSM[spectrum_id]['search_hit']:
        if( tmp_hit['TPP_pep_prob'] > best_prob ):
            best_xcorr = tmp_hit['xcorr']
            best_peptide = tmp_hit['peptide']
            best_protein = tmp_hit['protein']
            best_deltacn = tmp_hit['deltacn']
            missed_cleavages = tmp_hit['missed_cleavages']
            best_prob = tmp_hit['TPP_pep_prob']
    f_out.write("%s\t%s\t%f\t%s\t%s\t%d\t%f\t%f\t%f\n"%(spectrum_id,charge,neutral_mass,best_peptide,best_protein,missed_cleavages,best_xcorr,best_deltacn,best_prob))
    if( best_prob > 0.95 ):
        f_out95.write("%s\t%s\t%f\t%s\t%s\t%d\t%f\t%f\t%f\n"%(spectrum_id,charge,neutral_mass,best_peptide,best_protein,missed_cleavages,best_xcorr,best_deltacn,best_prob))
f_out.close()
f_out95.close()
