import marcottelab.Spectra2 as SP2

def read_sqt(filename_sqt):
  f_sqt = open(filename_sqt,'r')

  spectra_id = 1
  psm_id = 1
  header = dict()
  spectra = []
  hits = []
  current_spectra = SP2.Spectra2()
  current_match = PSM.PSM()

  for line in f_sqt:
    line = line.strip()
    if( line.startswith('H') ):
      tmp_H = line.split("\t")
      header_key = tmp_H[1].replace(" ",'_')
      header_value = ''
      if( len(tmp_H) == 3 ):
        header_value = tmp_H[2]
      if( header_key.startswith("Line_fields:_S") ):
        header['S_field'] = header_key.split(",_")
        del header['S_field'][0]
        header_key = 'S_field'
      elif( header_key.startswith("Line_fields:_M") ):
        header['M_field'] = header_key.split(",_")
        del header['M_field'][0]
        header_key = 'M_field'
      elif( header.has_key(header_key) ):
        header[header_key] = header[header_key]+':'+header_value
      else:
        header[header_key] = header_value

    elif( line.startswith('S') ):
      tmp_S = line.split("\t")
      current_spectra = SP2.Spectra2()
      current_spectra.init( charge= ,precursor_mass=, start_scan, end_scan=)
      
    elif( line.startswith('M') ):
      tmp_M = line.split("\t")
      current_match = PSM.SearchHit()
      current_match.init()

    elif( line.startswith('L') ):
      tmp_L = line.split("\t")
      current_match.set_protein( tmp_L[1] )
      current_spectra.append_match( current_match )

  f_sqt.close()
