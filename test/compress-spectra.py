#!/usr/bin/python2.5
import struct
import base64
import array

file_base = 'spectra_ORBI'
f_spectra = open(file_base+'.txt','r')

mz_list = array.array('d')
intensity_list = array.array('d')
for line in f_spectra:
  line = line.strip()
  tokens = line.split(" ")
  mz_list.append(float(tokens[0]))
  intensity_list.append(float(tokens[1]))
f_spectra.close()

count = len(mz_list)
f_ascii = open(file_base+'_ascii.encode','w')
f_ascii.write("%d\n" % count)
f_ascii.write( " ".join([ str(mz) for mz in  mz_list])+"\n" )
f_ascii.write( " ".join([ str(intensity) for intensity in intensity_list])+"\n" )
f_ascii.close()

packed_mz = ''
packed_intensity = ''
for mz in mz_list:
  packed_mz += struct.pack('d',mz)
for intensity in intensity_list:
  packed_intensity += struct.pack('d',intensity)

f_packed = open(file_base+'_packed.encode','w')
f_packed.write( packed_mz )
f_packed.write( packed_intensity )
f_packed.close()

unpacked_mz = struct.unpack('%dd'%count, packed_mz)
unpacked_intensity = struct.unpack('%dd'%count, packed_intensity)
f_unpacked = open(file_base+'_unpacked.encode','w')
f_unpacked.write("%d\n" % count)
f_unpacked.write( " ".join([ str(mz) for mz in  unpacked_mz ])+"\n" )
f_unpacked.write( " ".join([ str(intensity) for intensity in unpacked_intensity ])+"\n" )
f_unpacked.close()

f_base = open(file_base+'_base64.encode','w')
f_base.write("%d\n"%count)
f_base.write(base64.b64encode(packed_mz)+"\n")
f_base.write("__XXXXXX__\n")
f_base.write(base64.b64encode(packed_intensity)+"\n")
f_base.close()
