class SearchHit:
  def __init__(self):
    self.peptide = ''
    self.prev_aa = ''
    self.next_aa = ''
    self.peptide_mass = 0
    self.mass_diff = 0.0
    self.missed_cleavage = 0
    self.protein_list = set()

class CruxHit(SearchHit):
  def __init__(self):
    self.rank_by_xcorr = 0
    self.rank_by_sp = 0
    self.xcorr = 0.0
    self.sp = 0.0
    self.deltaCn = 0.0
    self.matched_ions = 0
    self.compared_ions = 0
    self.percolator_score = 0.0
    self.q_value = 0.0

class XTandemHit(SearchHit):
  def __init__(self):
    self.hyperscore = 0
    self.nextscore = 0
    self.bscore = 0
    self.yscore = 0
    self.expect = 0.0
