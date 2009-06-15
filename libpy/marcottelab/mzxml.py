#!/usr/bin/python
import sys
import base64
import struct
import xml.parsers.expat

from marcottelab.MSScan import MS1Scan, MS2Scan

class MzXML():
    def __init__(self):
        self.msLevel = 0
        self.current_tag = ''
        self.tag_level = 0
        self.MS1_list = []
        self.MS2_list = []

    def decode_spectrum(self,line):
        decoded = base64.decodestring(line)
        tmp_size = len(decoded)/4
        unpack_format1 = ">%dL" % tmp_size

        idx = 0
        mz_list = []
        intensity_list = []

        for tmp in struct.unpack(unpack_format1,decoded):
            tmp_i = struct.pack("I",tmp)
            tmp_f = struct.unpack("f",tmp_i)[0]
            if( idx % 2 == 0 ):
                mz_list.append( float(tmp_f) )
            else:
                intensity_list.append( float(tmp_f) )
            idx += 1
        
        return mz_list,intensity_list
    
    def _start_element(self,name,attrs):
        self.tag_level += 1
        self.current_tag = name
        if( name == 'precursorMz' ):
            self.MS2_list[-1].precursor_intensity = float(attrs['precursorIntensity'])
            self.MS2_list[-1].precursor_charge = int(attrs['precursorCharge'])

        if( name == 'scan' ):
            self.msLevel = int(attrs['msLevel'])
            if( self.msLevel == 1 ):
                tmp_ms = MS1Scan()
            elif( self.msLevel == 2 ):
                tmp_ms = MS2Scan()
            else:
                print "What is it?",attrs
                sys.exit(1)

            tmp_ms.id = int(attrs['num'])
            tmp_ms.peak_count = int(attrs['peaksCount'])
            tmp_ms.filter_line = attrs['filterLine']
            tmp_ms.retention_time = float(attrs['retentionTime'].strip('PTS'))
            tmp_ms.low_mz = float(attrs['lowMz'])
            tmp_ms.high_mz = float(attrs['highMz'])
            tmp_ms.base_peak_mz = float(attrs['basePeakMz'])
            tmp_ms.base_peak_intensity = float(attrs['basePeakIntensity'])
            tmp_ms.total_ion_current = float(attrs['totIonCurrent'])
            tmp_ms.list_size = 0
            tmp_ms.encoded_mz = ''
            tmp_ms.encoded_intensity = ''

            if( self.msLevel == 1 ):
                self.MS1_list.append(tmp_ms)
            elif( self.msLevel == 2 ):
                tmp_ms.ms1_id = self.MS1_list[-1].id
                self.MS2_list.append(tmp_ms)

    def _end_element(self,name):
        self.tag_level -= 1
        self.current_tag = ''
        self.msLevel == 0

    def _char_data(self,data):
        if( self.current_tag == 'precursorMz' ):
            self.MS2_list[-1].precursor_mz = float(data)

        if( self.current_tag == 'peaks' ):
            mz_list, intensity_list = self.decode_spectrum(data)
            mz_string = ''.join([struct.pack('>f',i) for i in mz_list])
            intensity_string = ''.join([struct.pack('>f',i) for i in intensity_list])
            if( self.msLevel == 1 ):
                self.MS1_list[-1].list_size += len(mz_list)
                self.MS1_list[-1].encoded_mz += base64.encodestring(mz_string)
                self.MS1_list[-1].encoded_intensity += base64.encodestring(intensity_string)

            elif( self.msLevel == 2 ):
                self.MS2_list[-1].list_size += len(mz_list)
                self.MS2_list[-1].encoded_mz += base64.encodestring(mz_string)
                self.MS2_list[-1].encoded_intensity += base64.encodestring(intensity_string)

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
        expat.EndElementHandler = self._end_element
        expat.CharacterDataHandler = self._char_data
        expat.Parse(content_xml)
