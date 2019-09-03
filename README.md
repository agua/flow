README

# flow

0. Introduction
1. Before You Install
2. Installation
3. Resources
4. Developers
5. License

## 0. Introduction

Flow is an open-source Bioinformatics workflow platform that enables non-root users to run Linux-based workflows in a wide variety of environments: Cloud, HPC, local machine and containers. Flow can be used in concert with Biorepo [www.github.com/agua/biorepo](www.github.com/agua/biorepo), an open-source Bioinformatics package manager. For further information, see [www.aguadev.org](www.aguadev.org).

### 1. Before You Install

#### 1.1 Hardware requirements

Memory   512MB RAM
Storage  230 MB

#### 1.2 Operating system

Supported operating systems

Ubuntu 16.04
Centos 7.3
OSX

#### 1.3 Software

Required software packages: 

Perl 5.10+
Git 1.6+

You can verify these versions with the following commands:

perl --version
git --version

Installation:

Ubuntu/Debian

sudo apt-get install -y git
sudo apt-get install -y cpanminus

Centos/Fedora/Redhat:

sudo yum install perl-devel
sudo yum install perl-CPAN
curl -L http://cpanmin.us | perl - --sudo App::cpanminus
sudo yum install git

OSX:

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git

curl -L https://install.perlbrew.pl | bash
perlbrew install perl-5.16.0


## 2. Installation


# 1. CLONE FROM PUBLIC GITHUB REPO


# SET 'FLOW_HOME' ENVIRONMENT VARIABLE.
# NB: CHOOSE A LOCATION WITHOUT ANY SPACES IN FOLDER NAMES

export FLOW_HOME=/Users/myusername
git submodule update --init --recursive --remote

# DOWNLOAD REPO AND GO INSIDE

git clone https://github.com/agua/flow

cd flow


# 2. ADD .gitmodules FILE

rm -fr .gitmodules

git rm -fr lib/extlib
git rm -fr lib/Conf
git rm -fr lib/DBase
git rm -fr lib/Doc
git rm -fr lib/Engine
git rm -fr lib/Exchange
git rm -fr lib/Ops
git rm -fr lib/Package
git rm -fr lib/Table
git rm -fr lib/Test
git rm -fr lib/Util
git rm -fr lib/Virtual
git rm -fr lib/Web

git submodule add -b dev  https://github.com/agua/agua-extlib extlib
git submodule add -b dev  https://github.com/agua/agua-conf lib/Conf
git submodule add -b dev  https://github.com/agua/agua-dbase lib/DBase
git submodule add -b dev  https://github.com/agua/agua-doc lib/Doc
git submodule add -b dev  https://github.com/agua/agua-engine lib/Engine
git submodule add -b dev  https://github.com/agua/agua-exchange lib/Exchange
git submodule add -b dev  https://github.com/agua/agua-file lib/File
git submodule add -b dev  https://github.com/agua/agua-ops lib/Ops
git submodule add -b dev  https://github.com/agua/agua-package lib/Package
git submodule add -b dev  https://github.com/agua/agua-table lib/Table
git submodule add -b dev  https://github.com/agua/agua-test lib/Test
git submodule add -b dev  https://github.com/agua/agua-util lib/Util
git submodule add -b dev  https://github.com/agua/agua-virtual lib/Virtual
git submodule add -b dev  https://github.com/agua/agua-web lib/Web


# 3. LOAD MODULES

git submodule init
git submodule update --init --recursive --remote


INSTALL ADDITIONAL HEADERS:

sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /


# 4. MANUALLY INSTALL MODULES

If the 'extlib' submodule does not have the appropriate branch for your OS and version, you can build your own branch with an OS-specific installation of the required Perl modules:


cd extlib
git checkout -b <OS>-<VERSION>

# SET PERL5LIB

export PERL5LIB=$FLOW_HOME/flow/extlib/lib/perl5:$FLOW_HOME/flow/extlib/lib/perl5/darwin-thread-multi-2level

# INSTALL cpanm

brew install cpanm


# INSTALL PERL MODULES

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



5. TEST

export PERL5LIB=/Users/kbsf633/flow/extlib/lib/perl5:/Users/kbsf633/flow/extlib/lib/perl5/darwin-thread-multi-2level:/Users/kbsf633/flow/lib

/Users/kbsf633/flow/bin/flow

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



## 3. Resources

See [http://www.aguadev.org](http://www.aguadev.org) for information on Flow, Biorepo and other related resources.

## 4. Developers

If you'd like to tweak, fix, customize or otherwise improve Biorepo or add packages to Flow, contact aguadev@gmail.com. 

## 5. License

MIT Licence (see LICENSE.txt file for details).


