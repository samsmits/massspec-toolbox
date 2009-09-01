sub get_path {
  my %rv; 
  my $file_conf = $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/config/path.conf';

  unless( -f $file_conf ) {
    print STDERR "config/path.conf is not available in masspec-toolbox\n";
    exit;
  }
  
  if(not -f './DB/DBINFO' and not -f '../DB/DBINFO' ) {
    print STDERR "'DB' file is not available on parent directory.\n";
    print STDERR "Make 'DB' file containing full path of DB file.\n";
    exit;
  }

  open(CONF,$ENV{'MASSSPEC_TOOLBOX_HOME'}.'/config/path.conf');
  while(<CONF>) {
    next if(/^#/);
    next unless(/^[A-z0-9]+/);
    chomp;
    my ($key, $path) = split(/\s+/);
    $path =~ s/MASSSPEC_TOOLBOX_HOME/$ENV{'MASSSPEC_TOOLBOX_HOME'}/g;
    $rv{$key} = $path;
  }
  close(CONF);

  if( -f '../DB/DBINFO' ) { open(DB,"../DB/DBINFO"); }
  elsif( -f './DB/DBINFO' ) { open(DB,"./DB/DBINFO"); }

  my $db_line = <DB>; chomp($db_line);
  ($rv{'taxonomy'}, $rv{'DB'}) = split(/\s+/,$db_line);
  close(DB);

  return \%rv;
}

1;
