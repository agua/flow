CREATE TABLE IF NOT EXISTS stageparameter
(
  owner           VARCHAR(30) NOT NULL,
  username        VARCHAR(30) NOT NULL,
  projectname     VARCHAR(20) NOT NULL,
  workflowname    VARCHAR(20) NOT NULL,
  workflownumber  INT(12),

  appname         VARCHAR(40) NOT NULL,
  appnumber       VARCHAR(10) NOT NULL,
  paramname       VARCHAR(40) NOT NULL,
  paramnumber     VARCHAR(10) NOT NULL,

  ordinal         INT(6),
  locked          INT(1),
  paramtype       VARCHAR(40) NOT NULL,
  category        VARCHAR(40),
  valuetype       VARCHAR(20),
  argument        VARCHAR(255),
  value           TEXT,
  discretion      VARCHAR(10),
  format          VARCHAR(40),
  description     TEXT, 
  args            TEXT,
  inputParams     TEXT,
  paramFunction   TEXT,

  chained         INT(1),
  
  PRIMARY KEY  (username, projectname, workflowname, workflownumber, appnumber, paramname, paramnumber, paramtype, ordinal)
);
