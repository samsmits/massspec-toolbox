#!/usr/bin/python2.5
import marcottelab.spectra as spectra
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

f_base = open(file_base+'_base64.encode','w')
f_base.write("%d\n"%count)
f_base.write(spectra.encode_double_list(mz_list)+"\n")
f_base.write("__XXXXXX__\n")
f_base.write(spectra.encode_double_list(intensity_list)+"\n")
f_base.close()
