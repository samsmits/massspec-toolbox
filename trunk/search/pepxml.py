import xml.sax

class pepxml_parser(xml.sax.ContentHandler):
    element_array = []
    is_spectrum_query = False
    is_search_hit = False
    PSM = dict()
    search_hit = dict()
    spectrum_id = ''

    def startElement(self,name,attr):
        self.element_array.append(name)
        if( len(self.element_array) == 3 and name == 'spectrum_query' ):
            self.is_spectrum_query = True
            self.spectrum_id = attr['spectrum']
            if( not self.PSM.has_key(self.spectrum_id) ):
                self.PSM[self.spectrum_id] = dict()
                self.PSM[self.spectrum_id]['search_hit'] = []
            else:
                print "Duplicate PSM : %s"%self.spectrum_id
            self.PSM[self.spectrum_id]['charge'] = int(attr['assumed_charge'])
            self.PSM[self.spectrum_id]['neutral_mass'] = float(attr['precursor_neutral_mass'])
        if( len(self.element_array) == 5 and name == 'search_hit' ):
            self.is_search_hit = True
            self.search_hit = dict()
            self.search_hit['peptide'] = attr['peptide']
            self.search_hit['protein'] = attr['protein']
        if( len(self.element_array) == 6 and name == 'search_score' ):
            if(attr['name'] == 'xcorr'):
                self.search_hit['xcorr'] = float(attr['value'])
            if(attr['name'] == 'spscore'):
                self.search_hit['spscore'] = float(attr['value'])
            if(attr['name'] == 'deltacn'):
                self.search_hit['deltacn'] = float(attr['value'])
            
    def endElement(self,name):
        if( len(self.element_array) == 3 and name == 'spectrum_query' ):
            self.spectrum_id = ''
            self.is_spectrum_query = False
        if( len(self.element_array) == 5 and name == 'search_hit' ):
            self.PSM[self.spectrum_id]['search_hit'].append(self.search_hit)
            self.search_hit = dict()
            self.is_search_hit = False
        self.element_array.pop()
    
def parse_by_filename(filename_pepxml):
    p = pepxml_parser()
    xml.sax.parse(filename_pepxml,p)
    return p.PSM
