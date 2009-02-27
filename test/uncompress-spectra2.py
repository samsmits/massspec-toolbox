#!/usr/bin/python2.5
import marcottelab.spectra as spectra
import array

file_base = 'spectra_ORBI'

encoded_mz = ''
encoded_intensity = ''
f_encoded = open(file_base+'_base64.encode','r')
count = int(f_encoded.readline())
tmp = ''
for line in f_encoded:
  line = line.strip()
  if( line == '__XXXXXX__' ):
    encoded_mz = tmp
    tmp = '';
  else:
    tmp += line
f_encoded.close()
encoded_intensity = tmp

unpacked_mz = spectra.decode_double_list(count,encoded_mz)
unpacked_intensity = spectra.decode_double_list(count,encoded_intensity)

f_unpacked = open(file_base+'_ascii.decode','w')
f_unpacked.write("%d\n"%count)
f_unpacked.write( " ".join([ str(mz) for mz in unpacked_mz])+"\n" )
f_unpacked.write( " ".join([ str(intensity) for intensity in unpacked_intensity])+"\n" )
f_unpacked.close()
