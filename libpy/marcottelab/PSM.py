import Spectra

class SearchHit:
  def __init__(self):
    self.spectra = Spectra()
    self.peptide = ''
    self.prev_aa = ''
    self.next_aa = ''
    self.protein = ''
