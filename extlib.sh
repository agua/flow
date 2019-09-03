#!/usr/bin/perl -w

my $os = $^O;
my $system = undef;
my $archname = undef;
if ( $os eq "darwin" ) {
  $system = "darwin";
  $archname=`sw_vers | grep ProductVersion`;
  $archname =~ s/ProductVersion:\s+//;  
  $archname =~ s/\s+//g;
  print "Getting OSX version... $archname\n";
}
elsif ( $os eq "linux" ) {
  print "Loading extlib for Linux\n";

  my $osname=`perl -V  | grep "archname="`;
  # print "osname: $osname\n";
  ($archname) = $osname =~ /archname=(\S+)/;
  print "archname: $archname\n";

  if ( -f "/etc/lsb-release" ) {
    print "Getting Ubuntu version...\n";
    my $version = `cat /etc/lsb-release | grep DISTRIB_RELEASE`;
    $version =~ s/DISTRIB_RELEASE=//;
    $version =~ s/\s+//;
    # print "version: $version\n";
    $system = "ubuntu$version";
    $system =~ s/\.//g;
    # print "system: $system\n";
  }
  elsif ( -f "/etc/centos-release" ) {
    print "Getting Centos version...\n";
    my $version = `cat /etc/centos-release | grep "CentOS Linux release"`;
    $version =~ s/CentOS Linux release//;
    $version =~ s/\s+\(Core\)\s*$//;
    $version =~ s/\s+\(Core\)\s*$//;
    $version =~ s/\.\d+$//;
    $version =~ s/\s+//;
    # print "version: $version\n";
    $system = "centos$version";
    $system =~ s/\.//g;
    # print "system: $system\n";
  }
  else {
    print "No LSB or CentOS release file found in /etc. This Linux flavor is not supported. Use 'perlmods' executable to install perl modules to extlib directory\n";
  }
}
elsif ( $os eq "MSWin32" ) {
  print "Loading extlib for Windows\n";

}

if ( $system and $archname ) {
  my $branch = "$system-$archname";
  print "Branch: $branch\n";

  use FindBin qw($Bin);
  # my $command = "cd $Bin/extlib; git system -f $branch origin/$branch; git checkout $branch";
  # my $command = "cd $Bin/extlib; git fetch origin $branch; git checkout $branch";
  my $command = "cd $Bin/extlib; git checkout -b $branch; git checkout $branch; git pull origin $branch";
  print "$command\n";
  `$command`;
}
