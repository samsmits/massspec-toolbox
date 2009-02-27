import struct
import base64

class MS1:
  def __init__(self):
    self.id = 0
    self.retention_time = 0
    self.mz_list = []
    self.intensity_list = []

class MS2:
  def __init__(self):
    self.start_scan_id = 0
    self.end_scan_id = 0
    self.charge = 0
    self.precursor_mass = 0
    self.SearchHit_list = []

def encode_double_list(double_list):
  packed = ''
  for tmp in double_list:
    packed += struct.pack('d',tmp)
  return base64.b64encode(packed)

def decode_double_list(count, encoded_string):
  return struct.unpack("%dd"%count, base64.b64decode(encoded_string))
