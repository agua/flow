CREATE TABLE IF NOT EXISTS stage (
  owner               VARCHAR(30) NOT NULL,
  packagename         VARCHAR(40) NOT NULL,
  version             VARCHAR(40) NOT NULL,
  installdir          VARCHAR(255) NOT NULL,

  username            VARCHAR(30) NOT NULL,
  projectname         VARCHAR(20) NOT NULL,
  workflowname        VARCHAR(20) NOT NULL,
  workflownumber      INT(12) NOT NULL,
  samplename        	VARCHAR(20) NOT NULL,
  
  appname             VARCHAR(40) NOT NULL,
  appnumber           INT(12) NOT NULL,
  apptype             VARCHAR(40),

  status              VARCHAR(20),
  ancestor            VARCHAR(3),
  successor           VARCHAR(3),
  
  location            VARCHAR(255),
  executor            VARCHAR(255),
  prescript           VARCHAR(255),
  cluster             VARCHAR(20),
  submit              INT(1),
  qsuboptions         VARCHAR(255),

  stderrfile          varchar(255),
  stdoutfile          varchar(255),

  queued              DATETIME,
  started             DATETIME,
  completed           DATETIME,
  workflowpid         INT(12),
  stagepid            INT(12),
  stagejobid          INT(12),
  
  description         TEXT,
  notes               TEXT,
  
  PRIMARY KEY  (username, projectname, workflowname, workflownumber, appnumber)
);