/* 
 * users schema for NX::Nebraska
 * MySQL
 */

CREATE TABLE realm (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL,
  url VARCHAR(128) DEFAULT NULL,
  UNIQUE (name)
)
ENGINE=INNODB;

INSERT INTO realm (name) VALUES ('nebraska');
INSERT INTO realm (name) VALUES ('twitter');

CREATE TABLE `user` (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL,
  realm_id INTEGER NOT NULL,
  FOREIGN KEY (realm_id) REFERENCES realm(id),
  UNIQUE (name, realm_id)
)
ENGINE=INNODB;

CREATE TABLE user_nebraska (
  user_id INTEGER PRIMARY KEY,
  FOREIGN KEY (user_id) REFERENCES user(id),
  
  username VARCHAR(64) NOT NULL,
  password VARCHAR(64) NOT NULL,
  UNIQUE (username)
)
ENGINE=INNODB;

CREATE TABLE user_twitter (
  user_id INTEGER PRIMARY KEY,
  FOREIGN KEY (user_id) REFERENCES user(id),
  
  twitter_user VARCHAR(128),
  twitter_user_id VARCHAR(128),
  twitter_access_token VARCHAR(128),
  twitter_access_token_secret VARCHAR(128)
)
ENGINE=INNODB;

CREATE TABLE user_facebook (
  user_id INTEGER PRIMARY KEY,
  FOREIGN KEY (user_id) REFERENCES user(id),
  
  session_key VARCHAR(128),
  session_expires VARCHAR(128),
  session_uid VARCHAR(128)
)
ENGINE=INNODB;

/*
 * INSERT INTO user (name, realm_id) VALUES ('drakon', 1);
 * INSERT INTO user (name, realm_id) VALUES ('lime', 1);
 * INSERT INTO user_nebraska (user_id, username, password) VALUES (1, 'drakon', 'easy');
 * INSERT INTO user_nebraska (user_id, username, password) VALUES (2, 'lime', 'easy');
 */