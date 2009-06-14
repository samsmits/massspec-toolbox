#!/usr/bin/python
import sys
import xml.parsers.expat

class MSScan():
  def __init__(self):
    self.id = 0
    self.peak_count = 0
    self.filter_line = ''
    self.retention_time = 0.0
    self.low_mz = 0.0
    self.high_mz = 0.0
    self.base_peak_mz = 0.0
    self.base_peak_intensity = 0.0
    self.total_ion_current = 0.0
    self.encoded_mz = ''
    self.encoded_intensity = ''

class MS1Scan(MSScan):
  def __init__(self):
    pass

class MS2Scan(MSScan):
  def __init__(self):
    precursor_mz = 0.0

class MzXML():
  def __init__(self):
    self.msLevel = 0
    self.current_tag = ''
    self.MS1_list = []

  def decode_spectrum(line):
    decoded = base64.decodestring(line)
    tmp_size = len(decoded)/4
    unpack_format1 = ">%dL" % tmp_size

    for tmp in struct.unpack(unpack_format1,decoded):
        tmp_i = struct.pack("I",tmp)
        tmp_f = struct.unpack("f",tmp_i)[0]
        print tmp,tmp_f

  def _start_element(self,name,attrs):
    self.current_tag = name
    if( name == 'scan' ):
      if( attrs['msLevel'] == '1' ):
        self.msLevel = 1
        tmp_ms = MS1Scan()
      elif( attrs['msLevel'] == '2' ):
        self.msLevel = 2
        tmp_ms = MS2Scan()

      tmp_ms.id = int(attrs['num'])
      tmp_ms.peak_count = int(attrs['peaksCount'])
      tmp_ms.filter_line = attrs['filterLine']
      tmp_ms.retention_time = float(attrs['retentionTime'].strip('PTS'))
      tmp_ms.low_mz = float(attrs['lowMz'])
      tmp_ms.high_mz = float(attrs['highMz'])
      tmp_ms.base_peak_mz = float(attrs['basePeakMz'])
      tmp_ms.base_peak_intensity = float(attrs['basePeakIntensity'])
      tmp_ms.total_ion_current = float(attrs['totIonCurrent'])

      if( self.msLevel == 1 ):
        self.MS1_list.append(tmp_ms)
      #elif( attrs['msLevel'] == '2' ):

        #print name,attrs

  def end_element(name):
    print name

  def _char_data(self,data):
    if( self.current_tag == 'peaks' and self.msLevel == 1):
      print data,"== peaks", self.MS1_list[-1].id

  def parse_file(self,filename_xml):
    sys.stderr.write("Read %s ... "%filename_xml)
    f_xml = open(filename_xml,'r')
    content_xml = ''
    for line in f_xml:
      content_xml += line
    f_xml.close()
    sys.stderr.write("Done\n")

    expat = xml.parsers.expat.ParserCreate()
    expat.StartElementHandler = self._start_element
    expat.CharacterDataHandler = self._char_data
    expat.Parse(content_xml)

    for tmp_ms1 in self.MS1_list:
      print tmp_ms1.id, tmp_ms1.peak_count, tmp_ms1.base_peak_mz, tmp_ms1.base_peak_intensity, tmp_ms1.total_ion_current

################################################################################
#filename_mzXML = '/home/linusben/MS.cygnus/test_20090116/mzXML/good-old.mzXML'
filename_mzXML = '/home/linusben/MS.cygnus/test_20090116/mzXML/test.mzXML'

mzXML = MzXML()
mzXML.parse_file(filename_mzXML)
