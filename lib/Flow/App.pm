use MooseX::Declare;
use Flow::Timer;
use Flow::Status;


class Flow::App with (Util::Logger, 
    Flow::Timer, 
    Flow::Status, 
    Flow::Database,
    Flow::Common) {

    use File::Path;
    use JSON;
	use Getopt::Simple;
    use Data::Dumper;
    use Flow::Parameter;

    #### Int
    has 'log'		=> ( isa => 'Int', is => 'rw', default 	=> 	2 	);  
    has 'printlog'	=> ( isa => 'Int', is => 'rw', default 	=> 	5 	);
    has 'appnumber' => ( isa => 'Int|Undef', is => 'rw', required => 0 );
    has 'ordinal'   => ( isa => 'Int|Undef', is => 'rw', default => undef, required => 0, documentation => q{Set order of appearance: 1, 2, ..., N} );
    has 'indent'    => ( isa => 'Int', is => 'ro', default => 15);
    has 'epochstarted'  => ( isa => 'Int|Undef', is => 'rw', default => undef );
    has 'epochstopped'  => ( isa => 'Int|Undef', is => 'rw', default => undef );
    has 'epochduration' => ( isa => 'Int|Undef', is => 'rw', default => undef );
    has 'stagepid'      => ( isa => 'Maybe', is => 'rw', default => undef );
    has 'stagejobid'    => ( isa => 'Maybe', is => 'rw', default => undef );
    has 'workflowpid'   => ( isa => 'Maybe', is => 'rw', default => undef );

    #### Bool
    has 'localonly'	=> ( isa => 'Bool|Undef', is => 'rw', default    => undef, documentation => q{Set to 1 if application should only be run locally, i.e., not executed on the cluster} );

    #### Maybe    
    has 'submit'    => ( isa => 'Maybe',     is => 'rw', default => undef );
    has 'epochqueued'   => ( isa => 'Maybe',     is => 'rw', default => undef );

    #### Str
    has 'envfile'   => ( isa => 'Str|Undef', is => 'rw', required   =>  0   );
    has 'logfile'   => ( isa => 'Str|Undef', is => 'rw', required   =>  0   );
    has 'owner'	    => ( isa => 'Str|Undef', is => 'rw', required => 0, default =>  undef );
    has 'packagename'	=> ( isa => 'Str|Undef', is => 'rw', required => 0 );
    has 'version'	=> ( isa => 'Str|Undef', is => 'rw', required => 0 );
    has 'installdir'=> ( isa => 'Str|Undef', is => 'rw', required => 0 );
    has 'appname'	    => ( isa => 'Str|Undef', is => 'rw', required => 0, documentation => q{Name of this object} );
    has 'apptype'	    => ( isa => 'Str|Undef', is => 'rw', required => 0, documentation => q{User-defined application type} );
    has 'url'	    => ( isa => 'Str|Undef', is => 'rw', required => 0, documentation => q{URL of application website} );
    has 'linkurl'	=> ( isa => 'Str|Undef', is => 'rw', required => 0, documentation => q{URL for application usage information (e.g., man pages, help)} );
    has 'location'	=> ( isa => 'Str|Undef', is => 'rw', required => 0 );
    has 'executor'	=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'prescript'	=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'description'=>( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'notes'	    => ( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'scrapefile'=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'usagefile'	=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'stdoutfile'=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'stderrfile'=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    
    #### STORED STATUS VARIABLES
    has 'status'	=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'locked'	=> ( isa => 'Int|Undef', is => 'rw', default => undef );
    has 'queued'	=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'started'	=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'completed'	=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    has 'duration'	=> ( isa => 'Str|Undef', is => 'rw', default => undef );
    # TRANSIENT VARIABLES
    #has 'args'	    => ( isa => 'ArrayRef[Str|Int]', is => 'rw', required => 0 );
    has 'format'    => ( isa => 'Str', is => 'rw', default => "yaml");
    has 'newname'	=> ( isa => 'Str', is => 'rw', required => 0 );
    has 'paramname'	=> ( isa => 'Str', is => 'rw', required => 0 );
    has 'argument'	=> ( isa => 'Str', is => 'rw', required => 0 );
    has 'field'	    => ( isa => 'Str', is => 'rw', required => 0 );
    has 'value'	    => ( isa => 'Str', is => 'rw', required => 0 );

    has 'inputfile' => ( isa => 'Str|Undef', is => 'rw', required => 0, default => undef );
    has 'appfile'   => ( isa => 'Str|Undef', is => 'rw', required => 0, default => undef );
    has 'cmdfile'   => ( isa => 'Str|Undef', is => 'rw', required => 0, default => undef );
    has 'outputfile'=> ( isa => 'Str|Undef', is => 'rw', required => 0, default => undef );
    has 'outputdir' => ( isa => 'Str|Undef', is => 'rw', required => 0, default => undef );
    has 'dbfile'    => ( isa => 'Str|Undef', is => 'rw', required => 0 );
    has 'dbtype'    => ( isa => 'Str|Undef', is => 'rw', required => 0 );
    has 'database'  => ( isa => 'Str|Undef', is => 'rw', required => 0 );
    has 'user'      => ( isa => 'Str|Undef', is => 'rw', required => 0 );
    has 'password'  => ( isa => 'Str|Undef', is => 'rw', required => 0 );

    #### Obj
    has 'parameters'=> ( isa => 'ArrayRef[Flow::Parameter]', is => 'rw', default => sub { [] } );
    has 'fields'    => ( isa => 'ArrayRef[Str|Undef]', is => 'rw', default => sub { ['appname', 'appnumber', 'owner', 'packagename', 'version', 'installdir', 'apptype', 'location', 'executor', 'prescript', 'description', 'notes', 'url', 'linkurl', 'status', 'submit', 'appfile', 'field', 'value', 'cmdfile', 'inputfile', 'outputfile', 'paramname', 'scrapefile', 'stdoutfile', 'stderrfile', 'queued', 'started', 'completed', 'duration', 'stagepid', 'stagejobid', 'workflowpid', 'log', 'printlog', 'app', 'argument', 'format'] } );
    has 'savefields' => ( isa => 'ArrayRef[Str]', is => 'rw', default => sub { ['appname', 'appnumber', 'owner', 'packagename', 'version', 'installdir', 'status', 'queued', 'started', 'completed', 'duration', 'locked', 'apptype', 'location', 'executor', 'prescript', 'description', 'notes', 'submit', 'url', 'linkurl', 'localonly', 'stdoutfile', 'stderrfile', 'stagepid', 'stagejobid', 'workflowpid'] } );
    has 'exportfields' => ( isa => 'ArrayRef[Str]', is => 'rw', default => sub { ['appname', 'appnumber', 'owner', 'packagename', 'version', 'installdir', 'status', 'submit', 'apptype', 'location', 'executor', 'prescript', 'description', 'notes', 'url', 'linkurl', 'localonly', 'stdoutfile', 'stderrfile', 'queued', 'started', 'completed', 'duration', 'stagepid', 'stagejobid', 'workflowpid'] } );
    has 'appfields' => ( isa => 'ArrayRef[Str]', is => 'rw', default => sub { ['appname', 'appnumber', 'owner', 'packagename', 'version', 'installdir', 'apptype', 'location', 'executor', 'prescript', 'description', 'notes', 'url', 'linkurl', 'localonly'] } );
    has 'force'     => ( isa => 'Maybe', 	 is => 'rw', required => 0 );
    has 'logfh'     => ( isa => 'FileHandle',is => 'rw', required => 0 );

	#### OBJECTS
    has 'args'		=> ( isa => 'HashRef|Undef', is => 'rw', default => sub { return {}; } );
    has 'conf' 	=> (
		is 		=>	'rw',
		isa 	=> 	'Conf::Yaml',
		lazy	=>	1,
		builder	=>	"setConf"
	);
 
method BUILD ($hash) {
	$self->_getopts();
    $self->initialise();
}

method initialise {
	$self->logCaller("");
    #my $inputfile   =   $self->inputfile();
    #$self->logDebug("inputfile", $inputfile);
    
    $self->inputfile($self->appfile()) if defined $self->appfile() and $self->appfile();
	my $inputfile	=	$self->inputfile();
	$self->logDebug("inputfile", $inputfile);
    #$self->logDebug("inputfile must end in '.app'") and exit
    #    if defined $self->inputfile()
    #    and $self->inputfile()
    #    and not $self->inputfile() =~ /\.app$/;
    
    #$self->logDebug("outputfile must end in '.app'") and exit
    #    if defined $self->outputfile()
    #    and $self->outputfile()
    #    and not $self->outputfile() =~ /\.app$/;
    
	$self->logDebug("AFTER initialise");
}

method getopts {
	$self->_getopts();
	$self->initialise();
}

method _getopts {
	#print "_GETOPTS\n";
	#$self->logDebug("Flow::Flow::_getopts    \@ARGV: @ARGV");
	my @temp = @ARGV;
	my $arguments = $self->arguments();
	
	my $olderr;
	open $olderr, ">&STDERR";	
	open(STDERR, ">/dev/null") or die "Can't redirect STDERR to /dev/null\n";
	my $options = Getopt::Simple->new();
	$options->getOptions($arguments, "Usage: blah blah");
	open STDERR, ">&", $olderr;

	#$self->logDebug("options->{switch}:");
	#print Dumper $options->{switch};
	my $switch = $options->{switch};
	my $args	=	{};
	foreach my $key ( keys %$switch ) {
		my $value	=	$switch->{$key};
		if ( defined $value ) {
			#print "ADDING TO ARGS value: $value\n";
			$args->{$key}	=	$value;
			$self->$key($value) if $self->can($key);
		}
	}
	#### LOG STARTS	
	$self->logDebug("args", $args);

	#### SET args
	$self->args($args);

	#### RESTORE @ARGV
	@ARGV = @temp;
}

method arguments {
    my $meta = $self->meta();

    my %option_type_map = (
        'Bool'     => '!',
        'Str'      => '=s',
        'Int'      => '=i',
        'Num'      => '=f',
        'ArrayRef' => '=s@',
        'HashRef'  => '=s%',
        'Maybe'    => ''
    );
    
    my $attributes = $self->fields();
    # $self->logDebug("attributes", $attributes);
    my $args = {};
    foreach my $attribute_name ( @$attributes ) {
        my $attr = $meta->get_attribute($attribute_name);
        next if not defined $attr or $attr =~ /^\s*$/;
        # $self->logDebug("$attribute_name attr: ***" .  $attr . "***");
        # $self->logDebug("attr", $attr);
        my $attribute_type  = $attr->type_constraint();
        $attribute_type =~ s/\|*Undef\|*//g;
        # $self->logDebug("xxx" . $attribute_type);
        
        # $attribute_type =~ s/\|.+$//;
        # $self->logDebug("attribute_type", $attribute_type);
        my $type = $option_type_map{$attribute_type};
        # $self->logDebug("type: " . $type);

        $args -> {$attribute_name} = {  type => $type };
    }
    # $self->logDebug("args", $args);
    
    return $args;
}

method lock {
    $self->locked(1);
    $self->logDebug("Locked application '"), $self->appname(), "'\n";
    #$self->logDebug("self->locked: "), $self->locked(), "\n";
}

method unlock {
    $self->locked(0);
    $self->logDebug("Unlocked application '"), $self->appname(), "'\n";
    #$self->logDebug("self->locked: "), $self->locked(), "\n";
}

method run {
    #$self->logDebug("App::run(app)");
    $self->logDebug("No location for app. Exiting") if not $self->location();
    
#        $self->logDebug("Application "), $self->ordinal(), " is locked: ", $self->appname(), "\n"              if $self->locked();
    return "locked" if $self->locked();
    
    #### WRITE BKP FILE
    my $bkpfile = '';
    $bkpfile .= $self->outputdir() . "/" if $self->outputdir();
    $bkpfile .= $self->ordinal() . "-" . $self->appname() . ".app.bkp";
    $self->outputfile($bkpfile);
    $self->_write();

    my $command = $self->_command();
    $self->logDebug("Running application "). $self->ordinal(). ": " . $self->appname() . "\n\n";
    $self->logDebug("$command\n");        

    #### LOG COMMAND
    my $section = "[app " . $self->ordinal() . " " . $self->appname() . "]\n";
    $self->logDebug($section);
    $self->logDebug();
    $self->logDebug($self->toString() . "\n");
    $self->logDebug("Command:\n\n" . $command . "\n\n\n");

    #### SET STARTED
    $self->setStarted();
    $self->logDebug("started application '"). $self->appname() . "': " . $self->started(). "\n";
    #$self->logDebug("wiki:");
    #$self->wiki();

    #### RUN COMMAND
    my $output = `$command`;
    $self->logDebug("output", $output);
    
    #### LOG OUTPUT
    $self->logDebug("Output:\n\n" . $output);
    $self->logDebug("\n\n");

    #### COLLECT APPLICATION COMPLETION SIGNAL
    my $label = '';
    my $status = 'unknown';
    my $sublabels = '';
    my $message = '';
    
    if ( $output =~ /---\[status\s+(\S+):\s+(\S+)\s*(\S*)\]/ms )
    {
        $label = $1;
        $status = $2;
        $sublabels = $3;
        $message = "Job label '$label' completion status: $status";
        $message .= " $sublabels" if defined $sublabels and $sublabels;
        $message .= "\n\n";
        $self->logDebug($message);
    }

    #### SET STATUS
    $self->status($status) if defined $status;
    $self->status("unknown") if not defined $status;
    
    #### SET completed
    $self->setcompleted();
    
    #### SET DURATION
    $self->setDuration();

    $self->logDebug("wiki:");
    $self->wiki();

    $self->logDebug("#FINISHED '") . $self->appname() . "': " . $self->completed() . ", duration: " . $self->duration() . "\n";

    return $self->status();
}

method command {
    print $self->_command(), "\n";
}

method _command {
    #### GENERATE RUN COMMAND
    $self->_orderParams();
    my $command = '';
    $command .= $self->executor() . "\\\n" if $self->executor;
    $command .= $self->location() . " \\\n";
    foreach my $parameter ( @{$self->parameters()} )
    {
        next if not defined $parameter->argument() or not $parameter->argument();
        $command .= " " . $parameter->argument() if $parameter->argument();
        $command .= " " . $parameter->value() if $parameter->value();
        $command .= " \\\n";
    }
    $command =~ s/\\\s*$//;
    
    return $command;
}

method param {
    $self->logDebug("App::param()");
    $self->_loadFile() if $self->appfile();

    require Flow::Parameter;
    my $param = Flow::Parameter->new();
    $param->getopts();
    #$self->logDebug("param:");
    #print $param->toString(), "\n";
    
    #### GET THE PARAM FROM params
    my $index = $self->_paramIndex($param);
    $self->logDebug("Can't find parameter among workflow's parameters:"), $param->toString(), "\n\n" and exit if not defined $index;
    #$self->logDebug("index", $index);
    
    my $parameter = ${$self->parameters()}[$index];       
    $parameter->getopts();
    #$self->logDebug("parameter:");
    #print $parameter->toString(), "\n";

    my $command = shift @ARGV;
    #$self->logDebug("command", $command);

    $parameter->$command();
    #$self->logDebug("parameter:");
    #print $parameter->toString(), "\n";

    $self->outputfile($self->inputfile());
    $self->_write($self->outputfile()) if $self->outputfile();
    
    return 1;
}

method replace {
    $self->logDebug("Flow::App::replace()");
    
    $self->_loadFile() if defined $self->appfile() and $self->appfile();
    
    $self->logDebug("BEFORE self->toString() :");
    print $self->toString();

    #### DO PARAMETERS
    my $parameters = $self->parameters();
    my $params = [];
    foreach my $parameter ( @$parameters )
    {
        $parameter->getopts();
        $parameter->replace();
    }

    $self->logDebug("AFTER self->toString() :");
    print $self->toString() ;

    $self->outputfile($self->inputfile());
    $self->_write() if $self->outputfile();
    
    return 1;
}

method loadCmd {
    $self->logDebug("App::loadCmd()");

    $self->logDebug("self:");
    print $self->toString(), "\n";

    my $cmdfile = $self->cmdfile();
    open(FILE, $cmdfile) or die "Can't open cmdfile: $cmdfile\n";
    $/ = undef;
    my $content = <FILE>;
    close(FILE) or die "Can't close cmdfile: $cmdfile\n";
    $/ = "\n";
    $content =~ s/,\\\n/,/gms;
    
    $self->_loadCmd($content);
}

method _loadCmd ($content) {

  my @lines = split "\n", $content;
  
  my $location = shift @lines;
  $location =~ s/^\s+//;
  $location =~ s/\s+$//;
  $location =~ s/\\$//;
  
  $self->location($location);
  $self->logDebug("location is empty. Exiting")
      and exit if not $self->location();

  if ( not $self->appname() ) {
      my ($appname) = $location =~ /([^\/^\\]+)$/;
      $self->name($appname);
  }
  $self->logDebug("appname is empty. Exiting")
      and exit if not $self->appname();

  my $ordinal = scalar(@{$self->parameters()}) + 1;
  foreach my $line ( @lines ) {
    next if $line =~ /^#/ or $line =~ /^>/
        or $line =~ /^rem/ or $line =~ /^\s*$/;
    $line =~ s/^\s+//;
    $line =~ s/\s+$//;
    $line =~ s/\\$//;

    my ($argument, $value) = $line =~ /^(\S+)\s*(.*)$/;
    my $param = $argument;
    $param =~ s/^\-+// if $param;
    $self->logDebug("param", $param);
    $self->logDebug("value", $value);

    my $parameter = Flow::Parameter->new(
        param       =>  $param,
        argument    =>  $argument,
        value       =>  $value,
        ordinal     =>  $ordinal
    );
    
    $self->_addParam($parameter);
    
    $ordinal++;
  }
  $self->_orderParams();

  $self->outputfile($self->inputfile());
  $self->_write() if $self->outputfile();
  
  return 1;
}

method _loadScript ($content) {
  $self->logDebug("content", $content);

	my ($appname)	=	$content	=~	/^\s*(\S+)/;
	$self->logDebug("appname", $appname);
	$self->appname($appname);
	
	$content	=~	s/^\s*\S+\s*\n//;
	$content	=~	s/\\\n//g;
	my $executor	=	undef;
	my $executable	=	undef;
	if ( $content =~ /^(.+?java\s+.+?\-jar)\s+(.+?\.jar)/) {
		$executor	=	$1;
		$executable	=	$2;
		$content	=~	s/^.+?java\s+.+?\-jar\s+.+?\.jar//;
	}
	$self->logDebug("executor", $executor);
	$self->logDebug("executable", $executable);

	my $tokens;
	@$tokens	=	split " ", $content;
	$self->logDebug("tokens", $tokens);	

  $executable = shift @$tokens if not defined $executable;
	$self->location($executable);
	
	my $ordinal	=	0;
	if ( defined $$tokens[0] and $$tokens[0] !~	/^[\-]+[^=]+/ ) {
		#$self->logDebug("\$\$tokens[0]", $$tokens[0]);
		#$self->logDebug("DOING subCommand");
		my $param	=	"subCommand";
		my $value	=	shift @$tokens;
		$ordinal	=	1;
		my $argument	=	undef;
		
    my $valuetype = $self->getValueType($value);          

    my $parameter = Flow::Parameter->new(
      param       =>  $param,
      valuetype   =>  $valuetype,
      argument    =>  $argument,
      value       =>  $value,
      ordinal     =>  $ordinal,

      log			=>	$self->log(),
      printlog	=>	$self->printlog(),
      logfile		=>	$self->logfile()
    );
    $self->_addParam($parameter);
	}

	$ordinal++;
	
	for ( my $i = 0; $i < @$tokens; $i++ ) {
		#$self->logDebug("tokens[$i]", $$tokens[$i]);
		if ( $$tokens[$i]	=~	/^\-+.+$/ ) {
			my $argument	=	$$tokens[$i];
			my ($param)		=	$argument	=~ /^\-+(.+)$/;
			my $value		=	undef;
			if ( $i < scalar(@$tokens) - 1
				and $$tokens[$i + 1] !~	/^\-+.+$/ ) {
				$value	=	$$tokens[$i + 1];
				$i++;
			}
      my $valuetype = $self->getValueType($value);       
            
			my $parameter = Flow::Parameter->new(
				param      	=>  $param,
				valuetype   =>  $valuetype,
				argument    =>  $argument,
				value       =>  $value,
				ordinal     =>  $ordinal,
                
				log			=>	$self->log(),
				printlog	=>	$self->printlog(),
				logfile		=>	$self->logfile()
			);
			#$self->logDebug("parameter", $parameter->toString());
      $self->_addParam($parameter);
		}
		elsif ( $$tokens[$i]	=~	/^.+\=.+/ ) {
			my ($argument, $value)	=	$$tokens[$i]	=~	/^(.+\=)(.+)/;	
            my $valuetype = $self->getValueType($value);          
			my ($param)	=	$argument	=~	/^(.+?)=$/;

			my $parameter = Flow::Parameter->new(
				param      	=>  $param,
				valuetype   =>  $valuetype,
				argument    =>  $argument,
				value       =>  $value,
				ordinal     =>  $ordinal,
                
				log			=>	$self->log(),
				printlog	=>	$self->printlog(),
				logfile		=>	$self->logfile()
			);
			#$self->logDebug("parameter", $parameter->toString());
      $self->_addParam($parameter);
		}
		else {
      my $value   =   $$tokens[$i];
      my $valuetype = $self->getValueType($value);          

			my $parameter = Flow::Parameter->new(
				param      	=>  "parameter." . $ordinal,
				valuetype   =>  $valuetype,
				value       =>  $value,
				ordinal     =>  $ordinal,
				
                log			=>	$self->log(),
				printlog	=>	$self->printlog(),
				logfile		=>	$self->logfile()
			);
	    $self->_addParam($parameter);
		}
		
		$ordinal++;
	}
	
  my $outputfile = $self->outputfile();
  $outputfile = $self->inputfile() if not defined $outputfile;
  # $self->_write($outputfile);
  
  return 1;
}

method getValueType ($value) {
    $self->logDebug("value", $value);
    my $valuetype = "string";
    $valuetype = "file" if $value =~ /\//;
    $valuetype = "directory" if $value =~ /\/[^\.^\/]+$/;
    $valuetype = "integer" if $value =~ /^\d+$/;
    $self->logDebug("valuetype", $valuetype);
    
    return $valuetype;    
}

method loadUsage {
#### CONVERT '--help' USAGE OUTPUT OF APPLICATION TO PARAMS LIST
    my $usagefile = $self->usagefile();
    $self->logDebug("usagefile", $usagefile);

    #### LOAD USAGE
    $self->_loadUsage($usagefile);
    
    ### PRINT TO FILE
    $self->outputfile($self->inputfile());
    $self->_write() if $self->outputfile();
}

method _loadUsage ($usagefile) {
    $self->logCaller("");
    $self->logDebug("usagefile", $usagefile);

    my $content = $self->getFileContents($usagefile);
    $content =~ s/,\\\n/,/gms;    
    $self->logNote("content", $content);

    ### CLEAR ALL CURRENT PARAMETERS
    $self->clear();
    
    #### PARSE ARGUMENT NAMES AND TYPES
    my $lines;
    @$lines = split "\n", $content;
    my $args;
    my $ordinal = 1;
    my $counter = 0;
    for ( $counter = 0; $counter < @$lines; $counter++ ) {
        my $line = $$lines[$counter];
        $self->logNote("line $counter", $line);

        last if $line =~ /^[^:]+:.+$/;

        next if $line =~ /^#/ or $line =~ /^>/
            or $line =~ /^rem/ or $line =~ /^\s*$/;
        $line =~ s/\s+$//;
        $line =~ s/\\$//;
        $self->logNote("line BEFORE REGEX, counter: $counter", $line);
        
        if ( $line =~ /^.*[\-]{1,2}(\S+)\s+([^\s^\]^\}^>]+)\s*/ ) {
            $self->logNote("line OK", $line);
 
            $args->{$1}->{type} =   $2;
            $args->{$1}->{ordinal} = $ordinal;
            $ordinal++;
        }
    }
    $self->logNote("FINAL counter", $counter);
    $self->logNote("args", $args);
    
    #### PARSE DESCRIPTIONS
    for ( my $i = $counter; $i < @$lines; $i++ ) {
        my $line = $$lines[$i];
        $self->logNote("Parsing line $i", $line);
        if ( $line =~ /^\s*([^:^\s]+)\s*:\s*(.+?)\s*$/ ) {
            my $parameter = $1;
            my $description = $2;
            
            $self->logNote("parameter", $parameter);
            $self->logNote("description", $description);
            $self->logNote("args->$parameter", $args->{$parameter});
                
            if ( exists $args->{$parameter} ) {
                $self->logNote("ADDING parameter->{description}", $description);
                $args->{$parameter}->{description} = $description;
            }
        }
    }
    
    #### ADD PARAMETERS
    foreach my $key (keys %$args) {                
        my $arg = $args->{$key};
        $self->logNote("arg", $arg);
        
        my $parameter = Flow::Parameter->new(
            param       =>  $key,
            argument    =>  "--$key",
            paramtype   =>  $arg->{type},
            description =>  $arg->{description},
            ordinal     =>  $arg->{ordinal}
        );
        
        $self->_addParam($parameter);
    }
    
    $self->_orderParams();

    return $self;
}

method loadScrape {
    #### CONVERT SCRAPE OF '--help' OUTPUT OF APPLICATION TO PARAMS LIST
    my $scrapefile = $self->scrapefile();
    #$self->logDebug("scrapefile", $scrapefile);

    open(FILE, $scrapefile) or die "Can't open scrapefile: $scrapefile\n";
    $/ = undef;
    my $content = <FILE>;
    close(FILE) or die "Can't close scrapefile: $scrapefile\n";
    $/ = "\n";
    $content =~ s/,\\\n/,/gms;
    
    $self->_loadScrape($content);
}

method _loadScrape ($content) {
    #$self->logDebug("App::_loadScrape(content)");
    #$self->logDebug("content", $content);

    my @lines = split "\n", $content;
    my ($argument, $long, $value);
    my $ordinal = 1;
    foreach my $line ( @lines )
    {
        next if $line =~ /^#/ or $line =~ /^>/
            or $line =~ /^rem/ or $line =~ /^\s*$/;
        $line =~ s/\s+$//;
        $line =~ s/\\$//;
        #$self->logDebug("line", $line);

        $line =~ s/://g;
        if ( $line =~ /^\s*(\-{1,2}\S+)\s+(\-{2}\S+\s+)?(.+)$/ ) {

            if ( defined $argument ) {
                $argument = $long if defined $long;
                my $param = $argument;
                $param =~ s/^\-+// if $param;
                #$self->logDebug("param", $param);
                #$self->logDebug("value", $value);
                
                my $parameter = Flow::Parameter->new(
                    param   =>  $param,
                    argument =>  $argument,
                    value   =>  $value,
                    ordinal =>  $ordinal
                );
                
                $self->_addParam($parameter);
                
                $ordinal++;
            }

            #$self->logDebug("argument", $argument) if defined $argument;
            #$self->logDebug("long", $long) if defined $long;
            #$self->logDebug("value", $value) if defined $value;

            $argument   =   $1;
            $long       =   $2;
            $value      =   $3;
            $value =~ s/^\s+// if defined $value;
            $value =~ s/\s+$// if defined $value;
            $long =~ s/\s+$// if defined $long;
        }
        else
        {
            $line =~ s/^\s+//g;
            $line =~ s/\s+$//g;
            $value .= " $line";
        }
    }

    $self->_orderParams();

    $self->outputfile($self->inputfile());
    $self->_write() if $self->outputfile();
    
    return 1;
}

method clear {
	#### GET ATTRIBUTES
	my $meta = Flow::App->meta();
	my $attributes;
	@$attributes = $meta->get_attribute_list();
	$self->logDebug("attributes", $attributes);

	#### RESET TO DEFAULT OR CLEAR ALL ATTRIBUTES
	foreach my $attribute ( @$attributes ) {
        next if $attribute eq "log";
        next if $attribute eq "printlog";
        next if $attribute eq "db";
        
		my $attr = $meta->get_attribute($attribute);
		my $required = $attr->is_required;
		$required = "undef" if not defined $required;
		my $default 	= $attr->default;
		my $isa  		= $attr->{isa};
		$isa =~ s/\|.+$//;		
		my $ref = ref $default;
		my $value 		= $attr->get_value($self);
		$self->logDebug("$attribute: $isa value", $value);
		next if not defined $value;

		if ( not defined $default ) {
			$self->logDebug("CLEARING NO-DEFAULT ATTRIBUTE $attribute: $isa value", $value);
			$attr->clear_value($self);
		}
		else {
			#$self->logDebug("SETTING VALUE TO DEFAULT", $default);
			if ( $ref ne "CODE" ) {
				$self->logDebug("SETTING TO DEFAULT ATTRIBUTE $attribute: $isa value", $value);
				$attr->set_value($self, $default);
			}
			else {
				$self->logDebug("SETTING TO DEFAULT CODE ATTRIBUTE $attribute: $isa value", $value);
				$attr->set_value($self, &$default);
			}
		}
		$self->logNote("CLEARED $attribute ($isa)", $attr->get_value($self));
	}

	#$self->loaded(0);
}

method descParam ($parameter) {
    $self->logDebug("App::desc()");
    $self->_loadFile();
    
    my $output = "\n";
    my $parameters = $self->parameters();
    foreach my $parameter ( @$parameters )
    {
        $output .= $parameter->_toString() . "\n";
    }
    $self->logDebug("$output");
}


method hasParam ($paramname) {
    $self->logDebug("paramname", $paramname);

    foreach my $currentparam ( @{$self->parameters()} ) {
        return 1 if $paramname eq $currentparam->param();
    }
    
    return;
}

method getParam ($paramname) {
    $self->logDebug("paramname", $paramname);

    foreach my $currentparam ( @{$self->parameters()} ) {
        $self->logDebug("currentparam->paramname()", $currentparam->paramname());
        #$self->logDebug("currentparam", $currentparam);
        return $currentparam if $paramname eq $currentparam->paramname();
    }
    
    return;
}

method loadParam ($args) {
    use Flow::Parameter;
    my $parameter = Flow::Parameter->new($args);
    #$self->logDebug("self", $self) if $args->{name} eq "filename";


    $self->_addParam($parameter);
    $self->_orderParams();
    #$self->logDebug("self", $self);
    
    $self->_write() if $self->appfile();
}

method addParam {
    $self->logDebug("");

	my $args	=	$self->args();
	$self->logDebug("args", $args);
    use Flow::Parameter;
	delete $args->{appfile};
	$self->logDebug("args", $args);

    my $parameter = Flow::Parameter->new($args);
    $parameter->getopts();
    $parameter->_loadFile() if $parameter->paramfile();
    
    my $inputfile = $self->inputfile();
    $self->logDebug("inputfile", $inputfile);

    $self->_loadFile() if $self->appfile();
    
    $self->_deleteParam($parameter);

    $self->_addParam($parameter);
	
    $self->_orderParams();
    
	my $outputfile		=	$self->outputfile();
    my $appname        	=   $self->appname() || $self->app();
	my $appfile			=	$self->appfile();
	$self->logDebug("appfile", $appfile);

	if ( defined $appfile ) {
		($appname)	=	$appfile	=~	/([^\/]+)\.app$/;
	}
    $self->logDebug("appname", $appname);

	my $outputdir		=	$self->outputdir() || ".";
	$outputfile			=	"$outputdir/$appname.app" if not defined $outputfile or $outputfile eq "";
	$self->logDebug("outputfile", $outputfile);
	
    $self->_write($outputfile);

	print "\n";
	print `cat $outputfile`;
}

method _addParam ($parameter) {
    #$self->logDebug("parameter", $parameter);
    #$self->logDebug("self:");
    #print $self->toString(), "\n";

    push @{$self->parameters()}, $parameter;
}

method deleteParam {
    $self->logDebug("App::deleteParam()");
    
    my $inputfile = $self->inputfile;

    $self->_loadFile() if $self->appfile();
    
    my $parameter = Flow::Parameter->new(
        param       =>  $self->paramname(),
        ordinal     =>  $self->ordinal()
    );
    
    $self->_deleteParam($parameter);

    $self->_write() if $self->appfile();
}

method _deleteParam ($parameter) {
    $self->logDebug("App::_deleteParam(parameter)");

    my $index;
    $index = $self->ordinal() - 1 if $self->ordinal()
        and $self->ordinal() !~ /^\s*$/;
    $index = $self->_paramIndex($parameter) if not defined $index;
    $self->logDebug("index", $index) if defined $index;

    return if not defined $index;
    
    splice @{$self->parameters}, $index, 1;

    $self->_orderParams();
}

method editParam ($parameter) {
    $self->logDebug("App::editParam(parameter)");
    
    $self->logDebug("parameter name (--param) not defined")
        and exit if not $parameter->param();

    $self->logDebug("parameter->param(): "). $parameter->param(). "\n";
    $self->logDebug("parameter->field(): "). $parameter->field(). "\n";
    $self->logDebug("parameter->value(): "). $parameter->value(). "\n";
    print $parameter->toString();

    my $inputfile = $self->inputfile;
    $self->logDebug("inputfile", $inputfile);

    $self->_loadFile();
    print $self->toJson(), "\n";
    
    my $index = $self->_paramIndex($parameter);
    $self->logDebug("index", $index);

    $self->_editParam(${$self->parameters()}[$index], $parameter->field(), $parameter->value());
    #print $self->toJson(), "\n";

    $self->_orderParams();
    #print $self->toJson(), "\n";
    
    $self->logDebug("Doing self->_write()");
    $self->_write();
}

method _editParam ($parameter, $field, $value) {

    $self->logDebug("(parameter, field, value)");
    $self->logDebug("field", $field);
    $self->logDebug("value", $value);
    $self->logDebug("BEFORE parameter->toString()");
    print $parameter->toString(), "\n";
    $parameter->edit($field, $value);
    $self->logDebug("AFTER parameter->toString()");
    print $self->toString(), "\n";
    $self->_write();
}

method desc {
    $self->logDebug("App::desc()");
    $self->_loadFile() if $self->inputfile();
    
    print $self->toString() and exit if not defined $self->field();
    my $field = $self->field();
    
    print $self->toJson(), "\n";
    
    $self->logDebug("field", $field);
    $self->logDebug("$field: ") , $self->$field(), "\n";
}

method wiki {
    $self->_loadFile() if $self->appfile();

    my $wiki = $self->_wiki();
    print $wiki;
    
    return 1;
}


method _wiki {
    #$self->logDebug("Workflow::_wiki()");
    my $wiki = '';
    $wiki .= "\n\tApplication";
    $wiki .= "\t" . $self->ordinal() if $self->ordinal();
    $wiki .= "\t" . $self->appname . "\n";
    $wiki .= "\t" . $self->location . "\n";
    $wiki .= "\tstatus: " . $self->status() . "\n" if $self->status();
    $wiki .= "\tlocked: " . $self->locked() . "\n" if $self->locked() !~ /^\s*$/;
    $wiki .= "\tstarted: " . $self->started() . "\n" if $self->started();
    $wiki .= "\tcompleted: " . $self->completed() . "\n" if $self->completed();
    $wiki .= "\tduration: " . $self->duration() . "\n" if $self->duration();
    $wiki .= "\n" if $self->started() . "\n";
    $wiki .= "\n";
    
    
    return $wiki;
}


method edit {
    #$self->logDebug("App::edit()");
    #$self->logDebug("self->toString():");
    #print $self->toString(), "\n";

    my $field = $self->field();
    my $value = $self->value();
    $self->logDebug("field: **$field**");
    $self->logDebug("value: **$value**");
    
    $self->_loadFile() if $self->inputfile();
    my $present = 0;
    foreach my $currentfield ( @{$self->fields()} ) {
        #$self->logDebug("currentfield: **$currentfield**");
        $present = 1 if $field eq $currentfield;
        last if $field eq $currentfield;
    }
    #$self->logDebug("present", $present);
    print "Flow::App::edit    field '$field' is not a valid app field\n" and exit if not $present;

    $self->$field($value);
    #$self->logDebug("Edited field '$field' value: "), $self->$field(), "\n";        
    #$self->logDebug("self:");
    #print $self->toString();

    $self->outputfile($self->inputfile());
    $self->_write($self->outputfile()) if $self->outputfile();
    
    return 1;
}

method create {
	$self->logDebug("");    
    
    my $outputfile 		= 	$self->outputfile;
    $outputfile     	=   $self->appfile() if not defined $outputfile;
    $self->logDebug("outputfile", $outputfile);
    my $appname        	=   $self->appname();
    $self->logDebug("appname", $appname);
    if ( not defined $appname ) {
        ($appname)   =   $self->appfile()  =~  /^(.+)\.app$/;
        $self->appname($appname);
    }
    $self->logDebug("appname", $appname);
    
	my $type		=	$self->type();
	print "Type not defined (use --type option)\n" and exit if not defined $type;
	
	my $outputdir		=	$self->outputdir() || ".";
	$outputfile			=	"$outputdir/$appname.app" if not defined $outputfile or $outputfile eq "";
	$self->logDebug("outputfile", $outputfile);
	
    $self->_write($outputfile);        

	print "\n";
	print `cat $outputfile`;
}

method copy {
    $self->logDebug("App::copy()");
    
    $self->_loadFile();
    $self->appname($self->newname());

    my $outputfile = $self->outputfile;
    $self->_confirm("Outputfile already exists. Overwrite?") if -f $outputfile and not defined $self->force();

    $self->_write();        
}

method convert {
	my $format		=	$self->format();
    $self->logDebug("format", $format);

    $self->_loadFile();

	#### SWITCH FORMAT
	if ( $format eq "json" ) {
		$format		=	"yaml" ;
	}
	else {
		$format		=	"json";
	}
	$self->logDebug("final format", $format);
	$self->format($format);

	my $appname		=	$self->appname();
	$self->logDebug("appname", $appname);

    my $outputfile = $self->outputfile();
    $self->_confirm("Outputfile already exists. Overwrite?") if -f $outputfile and not defined $self->force();

    $self->_write($outputfile);
}

method toHash {
	my $hash;
	#$self->logDebug("self->started(): "), $self->started(), "\n";
	foreach my $field ( @{$self->savefields()} ) {
		#$self->logDebug("field '$field' value: "), $self->$field(), "\n";

		next if not defined $self->$field();
		#next if $self->$field() eq "";

		if ( ref($self->$field) ne "ARRAY" ) {
			$hash->{$field} = $self->$field();
		}
	}
	$self->logDebug("hash", $hash);

	#### DO APPS
	my $parameters = $self->parameters();
	$self->logDebug("no. parameters", scalar(@$parameters));
	
	my $params = [];
	foreach my $parameter ( @$parameters ) {
		#$self->logDebug("parameter", $parameter);
		push @$params, $parameter->exportData();
	}
	$hash->{parameters} = $params;

	return $hash;
}

method _toExportHash ($fields) {
    #$self->log(4);
    #$self->logCaller("");
    #$self->logDebug("fields", $fields);
    my $hash;
    foreach my $field ( @$fields ) {
        #$self->logDebug("field $field: self->$field()", $self->$field() );
        next if not defined $self->$field();
		next if $self->$field() eq "";
		next if $self->$field() eq "0";
		next if $self->$field() eq "0000-00-00 00:00:00";

        next if ref($self->$field) eq "ARRAY";
        $hash->{$field} = $self->$field() if defined $self->$field();
        #$self->logDebug("DONE hash->{$field}", $self->$field() );
    }
    #$self->logDebug("hash", $hash);

    #### DO APPS
    my $parameters = $self->parameters();

    my $params = [];
    my $paramnumber = 1;
    foreach my $parameter ( @$parameters ) {
        $parameter->paramnumber($paramnumber) if not defined $parameter->paramnumber() or $parameter->paramnumber() eq "";
        $paramnumber++;
	    #$self->logDebug("parameter", $parameter);

        push @$params, $parameter->_exportParam();
    }
    
    $hash->{parameters} = $params;
    #$self->logDebug("Returning hash", $hash);

    return $hash;
}

method fromHash ($hash) { 
    $self->logDebug("hash", $hash);
    my $meta = $self->meta();

    foreach my $field ( keys %$hash ) {
        my $value = $hash->{$field};
        $self->logDebug("field $field value", $value);
        next if ref($self->$field) eq "ARRAY";
        
        my $attr = $meta->get_attribute($field);
        my $attribute_type  = $attr->{isa};
        $value = 0 if not $value and $attribute_type =~ /Int/;
        #$self->logDebug("'$field' attribute_type: $attribute_type and value: '$value'");
        
        $self->$field($value);
    }

    #### DO PARAMETERS
    my $paramHashes = $hash->{parameters};
    my $parameters = [];
    foreach my $paramHash ( @$paramHashes ) {
        push @$parameters, Flow::Parameter->new($paramHash);
    }
    $self->parameters($parameters);

    return $self;
}

method toJson {
    my $hash = $self->_toExportHash($self->savefields());
    my $jsonParser = JSON->new();
    my $json = $jsonParser->pretty->indent->encode($hash);
    return $json;    
}

method exportData {
    return $self->_toExportHash($self->exportfields());
}

method _indentSecond ($first, $second, $indent) {
    $second = "" if not defined $second;
    $indent = $self->indent() if not defined $indent;
    my $spaces = " " x ($indent - length($first));
    return $first . $spaces . $second;
}

method _paramIndex ($parameter) {
	#$self->logDebug("parameter", $parameter);
    my $counter = 0;
    foreach my $currentparam ( @{$self->parameters()} ) {
        if ( $parameter->param() eq $currentparam->param() ) {
            return $counter;
        }
        $counter++;
    }

    return;
}

method _orderParams {

    sub ordinalOrAbc (){
        #### ORDER BY ordinal IF PRESENT
        #my $aa = $a->ordinal();
        #my $bb = $b->ordinal();

        if ( not $a->paramname() or not $b->paramname() ) {

        }
        
        return $a->ordinal() <=> $b->ordinal()
            if defined $a->ordinal() and defined $b->ordinal()
            and $a->ordinal() and $b->ordinal();
            
        #### OTHERWISE BY ALPHABET
        #my $AA = $a->param();
        #my $BB = $b->param();
        #$self->logDebug("AA", $AA);
        #$self->logDebug("BB", $BB);
        return $a->paramname() cmp $b->paramname();
    }

    my $parameters = $self->parameters;
    # $self->logDebug("parameters", $parameters);
    @$parameters = sort ordinalOrAbc @$parameters;
    $self->parameters($parameters);
}

method _write($outputfile) {
    #$self->logDebug("Flow::App::_write(outputfile)");
    #$self->logDebug("outputfile", $outputfile) if defined $outputfile;
    
	$outputfile = $self->outputfile if not defined $outputfile;
	$outputfile = $self->inputfile if not defined $outputfile or not $outputfile;
	$self->logDebug("FINAL outputfile", $outputfile);

	my ($basedir) = $outputfile =~ /^(.+)(\/|\\)[^\/^\\]+$/;
	File::Path::mkpath($basedir) if defined $basedir and not -d $basedir;

	my $output	=	"";
	my $format	=	$self->format();
	$self->logDebug("format", $format);

	if ( $format eq "yaml" ) {
		require YAML::Tiny;
		my $yaml = YAML::Tiny->new();

		my $data	=	$self->toHash();
		$self->logDebug("data", $data);
		$yaml->[0]	=	$data;
		return $yaml->write($outputfile);
	}
	else {
		$output = $self->toJson();        
		open(OUT, ">$outputfile") or die "Can't open outputfile: $outputfile\n";
		print OUT "$output\n";
		close(OUT) or die "Can't close outputfile: $outputfile\n";
	}
}

method exportApp($outputfile) {
    $self->logDebug("outputfile", $outputfile);
    $outputfile = $self->outputfile if not defined $outputfile;
    $outputfile = $self->inputfile if not defined $outputfile or not $outputfile;

    #### CREATE BASE DIR
    my ($basedir) = $outputfile =~ /^(.+)(\/|\\)[^\/^\\]+$/;
    File::Path::mkpath($basedir) if defined $basedir and not -d $basedir;

    #### GET DATA
    my $data = $self->_toExportHash($self->appfields());
    $self->logDebug("data", $data);

    #### GET FORMAT
	my $format	=	$self->format();
	$self->logDebug("format", $format);

    #### PRINT TO FILE
	if ( $format eq "yaml" ) {
		require YAML::Tiny;
		my $yaml = YAML::Tiny->new();

		$yaml->[0]	=	$data;
		return $yaml->write($outputfile);
	}
	else {
        my $jsonParser = JSON->new();
        my $output = $jsonParser->pretty->indent->encode($data);

		open(OUT, ">$outputfile") or die "Can't open outputfile: $outputfile\n";
		print OUT "$output\n";
		close(OUT) or die "Can't close outputfile: $outputfile\n";
	}    
}

method read {
    return $self->_loadFile();
}

method _loadFile {
    #$self->logDebug("App::_loadFile()");

    my $inputfile = $self->inputfile;
    $self->logDebug("inputfile not specified") and exit if not defined $inputfile;
    $self->logDebug("Can't find inputfile", $inputfile) and exit if not -f $inputfile;
    
	my $object	=	undef;
	my $format	=	$self->format();
	$self->logDebug("format", $format);
   
    if ( $format eq "yaml" ) {
		$self->logDebug("Loading YAML file");
        require YAML::Tiny;
		my $yaml = YAML::Tiny->read($inputfile) or $self->logCritical("Can't open inputfile: $inputfile") and exit;
		$object 	=	$$yaml[0];
	}
	else {
		$self->logDebug("Loading JSON file");
		#$self->logDebug("inputfile", $inputfile);
		$/ = undef;
		open(FILE, $inputfile) or die "Can't open inputfile: $inputfile\n";
		my $contents = <FILE>;
		close(FILE) or die "Can't close inputfile: $inputfile\n";
		$/ = "\n";
	
		my $jsonParser = JSON->new();
		$object = $jsonParser->decode($contents);
	}

    my $fields = $self->fields();
    foreach my $field ( @$fields ) {
        if ( exists $object->{$field} and $object->{$field} ) {
            $self->$field($object->{$field});
        }
    }

    #### CREATE PARAMETERS
    $self->logDebug("Loading parameters");
    my $parameters = $self->parameters() || [];
    foreach my $paramhash ( @{$object->{parameters}} ) {
    $self->logDebug("paramhash", $paramhash);
        my $parameter = Flow::Parameter->new();
        $parameter->fromHash($paramhash);
    #$self->logDebug("parameter->toString():");
    #print $parameter->toString();

        push @$parameters, $parameter;
    }

    $self->parameters($parameters);
}

method _confirm ($message){

    $message = "Please input Y to continue, N to quit" if not defined $message;
    $/ = "\n";
    print "$message\n";
    my $input = <STDIN>;
    while ( $input !~ /^Y$/i and $input !~ /^N$/i )
    {
        print "$message\n";
        $input = <STDIN>;
    }	
    if ( $input =~ /^N$/i )	{	exit;	}
    else {	return;	}
}    

method toString{
    return $self->_toString();
    #$self->logDebug("$output");
}

method _toString {
    my $json = $self->toJson() . "\n";
    my $output = "\n  Application:\n";
    foreach my $field ( @{$self->savefields()} ) {
        next if not defined $self->$field() or $self->$field() =~ /^\s*$/;
        $output .= "  " . $self->_indentSecond($field, $self->$field(), $self->indent()) . "\n";
    }
    $output .= "\n    Parameters:\n";
    
    my $params;
    @$params = @{$self->parameters()};

    sub abcParams (){
        #### ORDER BY ALPHABET
        return $a->{paramname} cmp $b->{paramname};
    }
    @$params = sort abcParams @$params;

    foreach my $param ( @$params ) {

        my $paramname = $param->paramname();
        my $value = "";
        $value .= $param->argument() . " " if defined $param->argument() and $param->argument() ne "";
        $value .= $param->value() if defined $param->value() and $param->value() ne "";

        $output .= "    ". $self->_indentSecond($paramname, $value, undef) . "\n";
        #$output .= "\t" . $param->param(); 
        #$output .= "\t" . $param->value() if defined $param->value();
        #$output .= "\n"; 
    }
    
    return $output;
}


}
