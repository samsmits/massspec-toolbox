class SearchHit:
  def __init__(self):
    self.hit_rank = 0
    self.peptide = ''
    self.peptide_previ_aa = ''


search_hit = """<search_hit hit_rank="%(hit_rank)" peptide="%(peptide)" peptide_prev_aa="%(prev_aa)" peptide_next_aa="%(next_aa)" protein="%(protein)" num_tot_proteins="%(num_tot_proteins)" num_matched_ions="%(num_tot_ions)" tot_num_ions="%(tot_num_ions)" calc_neutral_pep_mass="%(calc_neutral_pep_mass)"
      massdiff="3.259" num_tol_term="1" num_missed_cleavages="0" 
      is_rejected="0">
  <search_score name="hyperscore" value="326"/>
  <search_score name="nextscore" value="325"/>
  <search_score name="bscore" value="1"/>
  <search_score name="yscore" value="1"/>
  <search_score name="expect" value="28"/>
</search_hit>"""

spectrum_query = \
"""<spectrum_query spectrum="with_spike_a.14.14.3" start_scan="14" end_scan="14" 
    precursor_neutral_mass="1510.96825252711" assumed_charge="3" index="7">
"""
