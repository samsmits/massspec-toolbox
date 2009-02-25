#!/usr/bin/python2.5
import marcottelab.inspect as inspect 
import marcottelab.pepxml as pepxml
import sys

file_inspect_out = sys.argv[1]
for rv in inspect.read_inspect_out(file_inspect_out).values():
  print rv.start_scan_id
