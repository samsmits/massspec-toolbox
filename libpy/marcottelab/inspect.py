import marcottelab.spectra as spectra
import marcottelab.PSM as PSM
import gzip

def read_inspect_out(filename):
  MS2_list = dict()

  if( filename.endswith('gz') ):
    f_inspect_out = gzip.open(filename,'r')
  else:
    f_inspect_out = open(filename,'r')

  header_idx = dict()
  tmp_idx = 0
  for header in f_inspect_out.readline().strip('#\r\n').split("\t"):
    header_idx[header] = tmp_idx
    tmp_idx += 1

  for line in f_inspect_out:
    tokens = line.strip().split("\t")
    start_scan_id = tokens[ header_idx['Scan#'] ]
    charge = tokens[ header_idx['Charge'] ]
    scan_id = ".".join( [start_scan_id, start_scan_id, charge] )
    peptides = tokens[ header_idx['Annotation'] ].split(".")

    current_hit = PSM.SearchHit()
    current_hit.peptide = "".join(peptides[1:-1])
    current_hit.prev_aa = peptides[0]
    current_hit.next_aa = peptides[-1]
    current_hit.peptide_mass = tokens[ header_idx['PrecursorMZ'] ]
    current_hit.significance = tokens[ header_idx['p-value'] ]
    current_hit.protein_list.append( tokens[ header_idx['Protein'] ] )

    if( not MS2_list.has_key( scan_id ) ):
      MS2_list[scan_id] = spectra.MS2()
      MS2_list[scan_id].charge = charge
      MS2_list[scan_id].start_scan_id = start_scan_id
      MS2_list[scan_id].end_scan_id = start_scan_id
      MS2_list[scan_id].precursor_mass = tokens[ header_idx['PrecursorMZ'] ]

    MS2_list[scan_id].SearchHit_list.append( current_hit )

  f_inspect_out.close()
  
  return MS2_list

