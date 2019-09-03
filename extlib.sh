#!/usr/bin/perl -w

my $os = $^O;
my $branch = undef;
my $archname = undef;
if ( $os eq "darwin" ) {
  print "Loading extlib for OSX\n";

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
    $branch = "ubuntu$version";
    $branch =~ s/\.//g;
    # print "Branch: $branch\n";
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
    $branch = "centos$version";
    $branch =~ s/\.//g;
    # print "Branch: $branch\n";
  }
  else {
    print "No LSB or CentOS release file found in /etc. This Linux flavor is not supported. Use 'perlmods' executable to install perl modules to extlib directory\n";
  }
}
elsif ( $os eq "MSWin32" ) {
  print "Loading extlib for Windows\n";

}

if ( $branch and $archname ) {
  print "extlib branch: $branch-$archname\n";

  use FindBin qw($Bin);
  # print "Bin: $Bin\n";
  my $command = "cd $Bin/extlib; git branch -f $branch-$archname origin/$branch-$archname; git checkout $branch-$archname";
  print "$command\n";
  `$command`;
}
