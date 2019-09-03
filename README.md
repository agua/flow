README  
  
# flow  
  
0. Introduction  
1. Before You Install  
2. Installation  
3. Resources  
4. Developers  
5. License  
  
### 0. Introduction  
  
Flow is an open-source Bioinformatics workflow platform that enables non-root users to run Linux-based workflows in a wide variety of environments: Cloud, HPC, local machine and containers. Flow can be used in concert with Biorepo [www.github.com/agua/biorepo](www.github.com/agua/biorepo), an open-source Bioinformatics package manager. For further information, see [www.aguadev.org](www.aguadev.org).  
  
### 1. Before You Install  
  
#### 1.1 HARDWARE REQUIREMENTS  
  
Memory   512MB RAM  
Storage  230 MB  
  
#### 1.2 OPERATING SYSTEM  
  
Supported operating systems  
  
Ubuntu 16.04  
Centos 7.3  
OSX  
  
#### 1.3 DEPENDENCIES  
  
Required software package dependencies:   
  
Perl 5.10+  
Git 1.6+  
  
You can verify these versions with the following commands:  
  
perl --version  
git --version  
  
Install dependencies:  
  
*Ubuntu/Debian*  
sudo apt install -y git  
  
*Centos/Fedora/Redhat*  
sudo yum install perl-devel  
sudo yum install perl-CPAN  
sudo yum install git  
  
*OSX*  
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"  
brew install git  
curl -L https://install.perlbrew.pl | bash  
perlbrew install perl-5.16.0  
  
  
### 2. Installation  
  
#### 2.1 SET 'FLOW_HOME' ENVIRONMENT VARIABLE.  
(NB: CHOOSE A LOCATION WITHOUT ANY SPACES IN FOLDER NAMES)  
  
export FLOW_HOME=/Users/myusername  
cd $FLOW_HOME  
  
#### 2.2 INSTALL flow  
  
CLONE AND INITIALISE SUBMODULES  
  
git clone https://github.com/agua/flow --recursive  
  
OR INITIALIZE SUBMODULES AFTER CLONE  
  
git clone https://github.com/agua/flow   
git submodule update --init --recursive  
    
#### 2.3 SELECT OS-SPECIFIC BRANCH OF extlib  
  
cd $FLOW_HOME  
./extlib.sh  

SEE 'Manual installation' BELOW IF THIS SCRIPT FAILS.
  
  
### 3. Manual installation of extlib 
  
If the 'extlib.sh' script above fails to find an OS-specific branch that matches your OS and version, follow these steps to create a new branch and install your OS-specific copies of the required Perl modules.  
  
#### 3.1 INSTALL ADDITIONAL HEADERS (OSX only)  
  
sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /  
  
#### 3.2 INSTALL cpanm  
  
*Ubuntu*  
sudo apt-get install -y cpanminus  
OR  
curl -L http://cpanmin.us | perl - --sudo App::cpanminus  
  
*CentOS*  
curl -L http://cpanmin.us | perl - --sudo App::cpanminus  
  
OSX  
brew install cpanm  
  
#### 3.3 INSTALL PERL MODULES  

*CHECKOUT NEW BRANCH (OS: darwin|centos|ubuntu, VERSION: *  
cd $FLOW_HOME/extlib  
git checkout -b <OS>-<VERSION>  
  
*SET PERL5LIB*  
export PERL5LIB=$FLOW_HOME/flow/extlib/lib/perl5:$FLOW_HOME/flow/extlib/lib/perl5/darwin-thread-multi-2level  
  
*INSTALL MODULES*  
cpanm install Test::Simple    -L .  
cpanm install Term::ReadKey   -L .  
cpanm install JSON            -L .  
cpanm install TAP::Harness::Env  -L .  
cpanm install Moose           -L .  
cpanm install LWP             -L .  
cpanm install MooseX::Declare -L .  
cpanm install TryCatch        -L .  
cpanm install Acme::Damn      -L .  
cpanm install AnyEvent@7.15        -L . --force  
cpanm install YAML::Tiny      -L . --force  
cpanm install Net::RabbitMQ   -L . --force  
cpanm install Fatal           -L .  
cpanm install Mouse::Tiny     -L .  
cpanm install Mouse           -L .  
cpanm install Method::Signatures::Modifiers -L .  
cpanm install Method::Signatures::Simple -L .  
cpanm install PadWalker       -L .  
cpanm install Getopt::Simple  -L .  
cpanm install FindBin::Real   -L .  
cpanm install DBI             -L .  
cpanm install DBD::SQLite     -L .  
cpanm install File::Sort      -L .  
cpanm install YAML      -L .  
  

### 4. Test flow

Once flow is installed and extlib is configured, you can test the 'flow' executable in the 'bin' folder.

*SET PERL5LIB*
 
export PERL5LIB=$FLOW_HOME/flow/extlib/lib/perl5:$PERL5LIB  
export PERL5LIB=$FLOW_HOME/flow/extlib/lib/perl5/darwin-thread-multi-2level:$PERL5LIB  
export PERL5LIB=:$FLOW_HOME/flow/lib:$PERL5LIB  

*ADD flow TO PATH* 

export PATH=$FLOW_HOME/flow/bin:$PATH  

(NB: ADD TO .bash_profile TO PERMANENTLY ENABLE THE flow COMMAND)  


*RUN flow*

flow
  
	FLOW(1)               User Contributed Perl Documentation              FLOW(1)  
  
  
  
  
	       APPLICATION  
  
	           flow  
  
	       PURPOSE  
  
	           Create, run and monitor workflows  
  
	       USAGE: flow <subcommand> [switch] [Options] [--help]  
  
	        subcommand   String :  
  
	           list            List all projects and contained workflows  
	           addproject      Add a new project  
	           deleteproject   Delete a project  
	           addworkflow     Add a workflow to an existing project  
	           deleteworkflow  Delete a workflow from a project  
	           addapp          Add an application to a workflow in an existing project  
	           deleteapp       Delete an application from a workflow  
  
	        package      String :    Name of package to install  
  
	        Options:  
  
	        subcommand     :    Type of workflow object (work|app|param)  
	        switch   :    Nested object (e.g., work app, app param)  
	        args     :    Arguments for the selected subcommand  
	        --help   :    print help info  
  
	       EXAMPLES  
  
	        # Add project to database  
	        flow addproject Project1  
  
	        # Add workflow 'Workflow1' file to project 'Project1'  
	        flow addworkflow Project1 ./workflow1.wrk  
  
	        # Create a workflow file with a specified name  
	        ./flow work create --wkfile /workflows/workflowOne.wk --name workflowOne  
  
	        # Add an application to workflow file  
	        ./flow work addapp --wkfile /workflows/workflowOne.wk --appfile /workflows/applicationOne.app --name applicationOne  
  
	        # Run a single application in a workflow  
	        ./flow work app run --wkfile /workflows/workflowOne.wk --name applicationOne  
  
	        # Run all applications in workflow  
	        ./flow work run --wkfile /workflows/workflowOne.wk  
  
	        # Create an application file from a file containing the application run command  
	        ./flow app loadCmd --cmdfile /workflows/applicationOne.cmd --appfile /workflows/applicationOne.app --name applicationOne  
  
  
  
	perl v5.18.4                      2019-09-01                           FLOW(1)  
  
  
  
### 5. Resources  
  
See [http://www.aguadev.org](http://www.aguadev.org) for information on Flow, Biorepo and other related resources.  
  
### 6. Developers  
  
If you'd like to tweak, fix, customize or otherwise improve or add to the package, contact stuartpyoung@gmail.com.   
  
### 7. License  
  
MIT Licence (see LICENSE.txt file for details).  
  
  
  