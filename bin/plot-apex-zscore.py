#!/usr/bin/python
import sys
import os
import math
import scipy.stats as stats
import matplotlib.pyplot as plt

usage_mesg = 'Usage: plot-apex-zscore.py <.zscore file>'
if( len(sys.argv) != 2 ):
  print usage_mesg
  sys.exit(1)

filename_zscore = sys.argv[1]
if( not os.access(filename_zscore,os.R_OK) ):
  print "Cannot access %s\n"%filename_zscore
  print usage_mesg
  sys.exit(1)
filename_zscore_png = filename_zscore+'.png'

file_zscore = open(filename_zscore,'r')
file1_name = 'unknown'
file2_name = 'unknown'
apex1_list = []
apex2_list = []
apex1_sig_list = []
apex2_sig_list = []
apex1_log_list = []
apex2_log_list = []
apex_min = 0
apex_max = 0
count_all = 0
count_compared = 0
count_compared_up = 0
count_compared_down = 0
for line_zscore in file_zscore:
  if(line_zscore.startswith('#')):
    if( line_zscore.startswith('# FILE1') ):
      tokens = line_zscore.strip().split("\t")
      file_tokens = tokens[1].split('.')
      file1_name = file_tokens[0]
    elif( line_zscore.startswith('# FILE2') ):
      tokens = line_zscore.strip().split("\t")
      file_tokens = tokens[1].split('.')
      file2_name = file_tokens[0]
    continue

  tokens = line_zscore.strip().split("\t")
  protein_id = tokens[0]
  spectra1 = int(tokens[4])
  spectra2 = int(tokens[5])
  z_score = float(tokens[9])
  apex1 = float(tokens[11])
  apex2 = float(tokens[12])
  if( apex_min == 0 ):
    apex_min = apex1
    apex_max = apex1
  
  count_all += 1
  if( apex1 > 0 and apex2 > 0 ):
    count_compared += 1
    if( apex_min > apex1 ):
      apex_min = apex1
    if( apex_min > apex2 ):
      apex_min = apex2

    if( apex_max < apex1 ):
      apex_max = apex1
    if( apex_max < apex2 ):
      apex_max = apex2

    if( abs(z_score) >= 1.96 ):
      apex1_sig_list.append(apex1)
      apex2_sig_list.append(apex2)
      if( apex2 > apex1 ):
        count_compared_up += 1
      elif( apex2 < apex1 ):
        count_compared_down += 1

    apex1_list.append(apex1)
    apex2_list.append(apex2)
    apex1_log_list.append(math.log10(apex1))
    apex2_log_list.append(math.log10(apex2))
file_zscore.close()

(spearman_coeff, spearman_P) = stats.spearmanr(apex1_log_list,apex2_log_list)

plt.figure(figsize=(8,8))
plt.grid()
plt.xscale('log')
plt.yscale('log')
plt.title(filename_zscore)
plt.xlabel(file1_name)
plt.ylabel(file2_name)
plt.plot([apex_min,apex_max], [apex_min,apex_max], color='black')
plt.plot(apex1_list,apex2_list,'o',color='blue')
plt.plot(apex1_sig_list,apex2_sig_list,'o',color='red')
plt.text(apex_min, apex_max, '#proteins=%d,#proteins compared=%d'%(count_all,count_compared))
plt.text(apex_min, apex_max/2, '#DE proteins=%d(up:%d, down:%d)'%(len(apex1_sig_list),count_compared_up,count_compared_down))
plt.text(apex_min, apex_max/4, 'Spearman=%.3f'%spearman_coeff)
plt.savefig(filename_zscore_png)
#plt.show()

