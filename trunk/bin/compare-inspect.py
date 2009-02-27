#!/usr/bin/python2.5
import marcottelab.inspect as inspect 
import matplotlib.pyplot as plt
import sys,re
import math

usage = 'compare-inspect.py <inspect output file1> <inspect output file2>'
usage += ' <png file>(optional)'

if(len(sys.argv) != 3 and len(sys.argv) != 4):
  print usage
  sys.exit(1)

file1 = sys.argv[1]
file2 = sys.argv[2]
file_png = ''
if( len(sys.argv) == 4 ):
  file_png = sys.argv[3]

inspect1 = inspect.read_inspect_out(file1)
inspect2 = inspect.read_inspect_out(file2)

sample_name1 = file1
sample_name2 = file2
re_sample_name = re.compile('([A-z0-9\_]+)\.inspect')
if( re_sample_name.search(sample_name1) ):
  rv = re_sample_name.search(sample_name1)
  sample_name1 = rv.group(1)
if( re_sample_name.search(sample_name2) ):
  rv = re_sample_name.search(sample_name2)
  sample_name2 = rv.group(1)

proteins = dict()
peptides = dict()
for ms2 in inspect1.values():
  sorted_psm = ms2.SearchHit_list

  if( len(sorted_psm[0].protein_list) == 1 ):
    peptide = sorted_psm[0].peptide
    protein_id = sorted_psm[0].protein_list[0]
    if( not proteins.has_key(protein_id) ):
      proteins[protein_id] = dict()
      proteins[protein_id]['file1'] = 0
      proteins[protein_id]['file2'] = 0
    proteins[protein_id]['file1'] += 1

    if( not peptides.has_key(peptide) ):
      peptides[peptide] = dict()
      peptides[peptide]['file1'] = 0
      peptides[peptide]['file2'] = 0
    peptides[peptide]['file1'] += 1 

for ms2 in inspect2.values():
  sorted_psm = ms2.SearchHit_list

  if( len(sorted_psm[0].protein_list) == 1 ):
    peptide = sorted_psm[0].peptide
    protein_id = sorted_psm[0].protein_list[0]
    if( not proteins.has_key(protein_id) ):
      proteins[protein_id] = dict()
      proteins[protein_id]['file1'] = 0
      proteins[protein_id]['file2'] = 0
    proteins[protein_id]['file2'] += 1

    if( not peptides.has_key(peptide) ):
      peptides[peptide] = dict()
      peptides[peptide]['file1'] = 0
      peptides[peptide]['file2'] = 0
    peptides[peptide]['file2'] += 1 

sorted_protein_id = proteins.keys()
sorted_protein_id.sort()
count_protein = {'common':0, 'file1':0, 'file2':0}

protein_x = []
protein_y = []
for protein_id in sorted_protein_id:
  tmp_p = proteins[protein_id]
  if( tmp_p['file1'] > 2 and tmp_p['file2'] > 2 ):
    count_protein['common'] += 1
    #protein_x.append( math.log(tmp_p['file1'],10) )
    #protein_y.append( math.log(tmp_p['file2'],10) )
    protein_x.append( tmp_p['file1'])
    protein_y.append( tmp_p['file2'])
  elif( tmp_p['file1'] > 2 ):
    count_protein['file1'] += 1
  elif( tmp_p['file2'] > 2 ):
    count_protein['file2'] += 1

#print "Common : ",count_protein['common']
#print file1," : ",count_protein['file1']
#print file2," : ",count_protein['file2']

sorted_peptides = peptides.keys()
sorted_peptides.sort()
count_peptide = {'common':0, 'file1':0, 'file2':0}

peptide_x = []
peptide_y = []
for peptide in sorted_peptides:
  tmp_p = peptides[peptide]
  if( tmp_p['file1'] > 1 and tmp_p['file2'] > 1 ):
    count_peptide['common'] += 1
    peptide_x.append( tmp_p['file1'])
    peptide_y.append( tmp_p['file2'])
  elif( tmp_p['file1'] > 1 ):
    count_peptide['file1'] += 1
  elif( tmp_p['file2'] > 1 ):
    count_peptide['file2'] += 1

#print "Common peptides: ",count_peptide['common']
#print file1," peptides : ",count_peptide['file1']
#print file2," peptides : ",count_peptide['file2']

fig = plt.figure(figsize=(12,5))

ax1 = fig.add_subplot(121)
ax1.plot(protein_x, protein_y, 'o')
ax1.axis([0,100,0,100])
ax1.text(50,15,'Common proteins : %d'%count_protein['common'], fontsize=9)
ax1.text(50,11,'%s only : %d'%(sample_name1,count_protein['file1']), fontsize=9)
ax1.text(50,7,'%s only : %d'%(sample_name2,count_protein['file2']), fontsize=9)
ax1.set_title("# spectra per common proteins")
ax1.set_xlabel(sample_name1)
ax1.set_ylabel(sample_name2)

ax2 = fig.add_subplot(122)
ax2.plot(peptide_x, peptide_y, 'x')
ax2.axis([0,30,0,30])
ax2.text(15,5,'Common peptides : %d'%count_peptide['common'], fontsize=9)
ax2.text(15,4,'%s only : %d'%(sample_name1,count_peptide['file1']), fontsize=9)
ax2.text(15,3,'%s only : %d'%(sample_name2,count_peptide['file2']), fontsize=9)
ax2.set_title("# spectra per common peptides")
ax2.set_xlabel(sample_name1)
ax2.set_ylabel(sample_name2)

if( file_png == '' ):
  plt.show()
else:
  plt.savefig(file_png, format='png')
