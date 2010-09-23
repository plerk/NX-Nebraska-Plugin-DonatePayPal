--- MySQL as root:
CREATE USER 'nebraska'@'%' IDENTIFIED BY 'nebraska';
CREATE DATABASE nebraska /*!40100 DEFAULT CHARACTER SET utf8 */;
GRANT 
  SELECT, 
  INSERT, 
  UPDATE, 
  DELETE, 
  SHOW VIEW,
  CREATE,
  ALTER,
  INDEX,
  CREATE VIEW,
  DROP,
  CREATE TEMPORARY TABLES,
  LOCK TABLES
ON 
  nebraska.*
TO 
  'nebraska'@'%';

CREATE DATABASE nebraska_user /*!40100 DEFAULT CHARACTER SET utf8 */;
GRANT 
  SELECT, 
  INSERT, 
  UPDATE, 
  DELETE, 
  SHOW VIEW,
  CREATE,
  ALTER,
  INDEX,
  CREATE VIEW,
  DROP,
  CREATE TEMPORARY TABLES,
  LOCK TABLES
ON 
  nebraska_user.*
TO 
  'nebraska'@'%';
