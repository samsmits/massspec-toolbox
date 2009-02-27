#!/usr/bin/python2.5
import struct
import base64
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

unpacked_mz = struct.unpack("%dd"%count, base64.b64decode(encoded_mz))
unpacked_intensity = struct.unpack("%dd"%count, base64.b64decode(encoded_intensity))

f_unpacked = open(file_base+'_ascii.decode','w')
f_unpacked.write("%d\n"%count)
f_unpacked.write( " ".join([ str(mz) for mz in unpacked_mz])+"\n" )
f_unpacked.write( " ".join([ str(intensity) for intensity in unpacked_intensity])+"\n" )
f_unpacked.close()
