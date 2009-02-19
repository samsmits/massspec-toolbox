
def read_sqt(filename_sqt):
  f_sqt = open(filename_sqt,'r')

  spectra_id = 1
  psm_id = 1
  header = dict()
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

      print header_key,header[header_key]
      #tmp_H[1] = tmp_H[1].replace(" ","_")
      #print tmp_H[1],tmp_H[2]
    elif( line.startswith('S') ):
      tmp_S = line.split("\t")
    elif( line.startswith('M') ):
      tmp_M = line.split("\t")
    elif( line.startswith('L') ):
      tmp_L = line.split("\t")
  f_sqt.close()
