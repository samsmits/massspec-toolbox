import marcottelab.spectra as spectra
import marcottelab.PSM as PSM
import gzip

def read_sqt(filename_sqt):
  MS2_list = dict()

  if( filename_sqt.endswith('gz') ):
    f_sqt = gzip.open(filename_sqt,'r')
  else:
    f_sqt = open(filename_sqt,'r')

  lines_sqt = f_sqt.readlines()
  total_lines = len(lines_sqt)

  S_header_idx = {'scan_number':1, 'charge':3, 'precursor_mass':5, 'number_of_matches':8}
  M_header_idx = {'rank_by_xcorr':1, 'rank_by_sp_score':2, 'peptide_mass':3, 'deltaCn':4,\
                  'percolator_score':5, 'q_value':6, 'number_ions_matched':7, 'total_ion_compared':8,\
                  'sequence':9}
  header = dict()

  for line_idx in range(0,total_lines):
    line = lines_sqt[line_idx].strip()

    if( line.startswith('H') ):
      tmp_H = line.split("\t")
      header_key = tmp_H[1].replace(" ",'_')
      header_value = " ".join(tmp_H[2:])

      if( header.has_key(header_key) ):
        header[header_key] = header[header_key]+':'+header_value
      else:
        header[header_key] = header_value

    elif( line.startswith('S') ):
      tmp_S = line.split("\t")
      start_scan_id = tmp_S[ S_header_idx['scan_number'] ]
      charge = tmp_S[ S_header_idx['charge'] ]
      scan_id = ".".join([start_scan_id,start_scan_id,charge])
      precursor_mass = tmp_S[ S_header_idx['precursor_mass'] ]
      
      if( not MS2_list.has_key(scan_id) ):
        MS2_list[scan_id] = spectra.MS2()
        MS2_list[scan_id].charge = charge
        MS2_list[scan_id].start_scan_id = start_scan_id
        MS2_list[scan_id].end_scan_id = start_scan_id
        MS2_list[scan_id].precursor_mass = precursor_mass

    elif( line.startswith('M') ):
      tmp_M = line.split("\t")
      peptides = tmp_M[ M_header_idx['sequence'] ].split(".")

      current_hit = PSM.SearchHit()
      current_hit.peptide = "".join(peptides[1:-1])
      current_hit.prev_aa = peptides[0]
      current_hit.next_aa = peptides[-1]
      current_hit.peptide_mass = tmp_M[ M_header_idx['peptide_mass'] ]
      current_hit.significance = tmp_M[ M_header_idx['q_value'] ]

      line_idx += 1
      while( line_idx < total_lines and lines_sqt[line_idx].startswith('L') ):
        tmp_L = lines_sqt[line_idx].strip().split("\t")
        current_hit.protein_list.append( tmp_L[1] )
        line_idx += 1

      MS2_list[scan_id].SearchHit_list.append( current_hit )

  f_sqt.close()

  return MS2_list
