use MooseX::Declare;

class Test::Flow::Main with Test::Common extends Flow::Main	 {

use Data::Dumper;
use Test::More;
use FindBin qw($Bin);
use JSON;

use Test::Table::Main;

method testOrderYaml {
	diag("#### orderYaml");

  my $tests = [
    {
      yamlfile     => "$Bin/inputs/Bcl2fastq.prj",
      expectedfile =>  "$Bin/inputs/Bcl2fastq.expected.prj",
    }
  ];
  foreach my $test ( @$tests ) {
    my $yamlfile = $test->{yamlfile};
    my $expectedfile = $test->{expectedfile};
    # $self->logDebug("yamlfile", $yamlfile);
    my $contents = $self->fileContents( $yamlfile );
    $self->logDebug("contents", $contents);
    my $project = YAML::Load( $contents );
    $self->logDebug("project", $project);
    my $actual = $self->orderYaml( $project );
    $self->logDebug("actual", $actual);
    my $expected = $self->fileContents( $expectedfile );
    $self->logDebug("expected", $expected);

    ok($actual eq $expected, "correctly ordered output");
  }
}

method fileContents ($filename) {
  $self->logNote("filename", $filename);
  open(FILE, $filename) or die "Can't open filename: $filename\n";
  my $oldsep = $/;
  $/ = undef;
  my $contents = <FILE>;
  close(FILE);
  $/ = $oldsep;
  
  return $contents;
}



}   #### Test::Agua::Common::Workflow
