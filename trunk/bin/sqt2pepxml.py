#!/usr/bin/python2.5
import marcottelab.sqt as sqt
import marcottelab.pepxml as pepxml

filename_sqt = "/home/linusben/MS/YEAST_spike_20081011/sqt/20081017_WithSpike_1.target.sqt"

sqt.read_sqt(filename_sqt)
#print pepxml.search_hit
