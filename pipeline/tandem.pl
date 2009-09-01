sub tandem_taxonomy_xml {
  my %param = @_;
  my $rv = "<?xml version=\"1.0\"?>\n";
  $rv .= "<bioml label=\"x! taxon-to-file matching list\">\n";
  $rv .= "  <taxon label=\"$param{-'DB_name'}\">\n";
  $rv .= "  <file format=\"peptide\" URL=\"$param{'-fasta_pro'}\" />\n";
  $rv .= "  </taxon>\n";
  $rv .= "</bioml>";
  return $rv;
}

sub tandem_config_xml {
  my %param = @_;

  my $rv = '<?xml version="1.0" encoding="UTF-8"?><bioml>'."\n";
  $rv .= '<note type="input" label="list path, default parameters">';
  $rv .= $param{'-input_xml'}."</note>\n";

  $rv .= '<note type="input" label="spectrum, path">';
  $rv .= $param{'-mzXML'}."</note>\n";

  $rv .= '<note type="input" label="output, path">';
  $rv .= $param{'-output'}."</note>\n";

  $rv .= '<note type="input" label="output, log path">';
  if( exists $param{'-log'} ) {
    $rv .= $param{'-log'}."</note>\n";
  } else {
    $rv .= "</note>\n";
  }

  $rv .= '<note type="input" label="output, sequence path">';
  if( exists $param{'-seq'} ) {
    $rv .= $param{'-seq'}."</note>\n";
  } else {
    $rv .= "</note>\n";
  }

  $rv .= '<note type="input" label="list path, taxonomy information">';
  $rv .= $param{'-taxonomy'}."</note>\n";

  $rv .= '<note type="input" label="protein, taxon">';
  $rv .= $param{'-db_name'}."</note>\n";
 
  $rv .= '<note type="input" label="spectrum, parent monoisotopic mass error minus">2.0</note>
<note type="input" label="spectrum, parent monoisotopic mass error plus">4.0</note>
<note type="input" label="spectrum, parent monoisotopic mass error units">Daltons</note>
<note type="input" label="spectrum, parent monoisotopic mass isotope error">no</note>

<note type="input" label="residue, modification mass">57.021464@C</note>

<note type="input" label="protein, cleavage semi">yes</note>
<note type="input" label="scoring, maximum missed cleavage sites">2</note>
</bioml>';

  return $rv;
}

1;
