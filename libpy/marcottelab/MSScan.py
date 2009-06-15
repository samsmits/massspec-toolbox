#!/usr/bin/python
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
        self.list_size = 0
        self.encoded_mz = ''
        self.encoded_intensity = ''

class MS1Scan(MSScan):
    def __init__(self):
        pass

class MS2Scan(MSScan):
    def __init__(self):
        self.ms1_id = 0
        self.precursor_mz = 0.0
        self.precursor_intensity = 0.0
        self.precursorCharge = 0
