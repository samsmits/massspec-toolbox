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
  
