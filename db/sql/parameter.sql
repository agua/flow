CREATE TABLE IF NOT EXISTS parameter
(
  owner           VARCHAR(30) NOT NULL,
  username        VARCHAR(30) NOT NULL,
  packagename     VARCHAR(40) NOT NULL,
  version         VARCHAR(40) NOT NULL,
  installdir      VARCHAR(255) NOT NULL,    

  appname         VARCHAR(40) NOT NULL,
  apptype         VARCHAR(40),    
  paramname       VARCHAR(40) NOT NULL,

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

  PRIMARY KEY  (owner, appname, paramname, paramtype, ordinal)
);
