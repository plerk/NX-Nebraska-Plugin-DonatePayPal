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

INSERT INTO realm (name, url) VALUES ('nebraska', 'http://nebraska.wdlabs.com/doc/about');
INSERT INTO realm (name, url) VALUES ('twitter', 'http://twitter.com');
INSERT INTO realm (name, url) VALUES ('facebook', 'http://www.facebook.com');
INSERT INTO realm (name) VALUES ('anonymous');
INSERT INTO realm (name, url) VALUES ('flickr', 'http://www.flickr.com');

CREATE TABLE `user` (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL,
  realm_id INTEGER NOT NULL,
  FOREIGN KEY (realm_id) REFERENCES realm(id),
  UNIQUE (name, realm_id),
  flickr_user_id INTEGER DEFAULT NULL,
  FOREIGN KEY (flickr_user_id) REFERENCES user(id)
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

CREATE TABLE user_anon (
  user_id INTEGER PRIMARY KEY,
  FOREIGN KEY (user_id) REFERENCES user(id),
  free TINYINT(1) DEFAULT 0,
  modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  secret CHAR(64) CHARACTER SET latin1 NOT NULL
)
ENGINE=INNODB;

CREATE TABLE user_flickr (
  user_id INTEGER PRIMARY KEY,
  FOREIGN KEY (user_id) REFERENCES user(id),
  flickr_username VARCHAR(64) NOT NULL UNIQUE,
  flickr_nsid VARCHAR(64),
  flickr_token VARCHAR(64)
)
ENGINE=INNODB;

CREATE TABLE flickr_photo (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES user(id),
  flickr_webservice_id BIGINT NOT NULL UNIQUE,
  title VARCHAR(64) NOT NULL,
  url VARCHAR(128) NOT NULL
)
ENGINE=INNODB;

CREATE TABLE flickr_photo_url (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  flickr_photo_id INTEGER NOT NULL,
  FOREIGN KEY (flickr_photo_id) REFERENCES flickr_photo(id),
  `type` ENUM('m','s','t','sq') NOT NULL,
  width INTEGER NOT NULL,
  height INTEGER NOT NULL,
  url VARCHAR(128) NOT NULL,
  UNIQUE (flickr_photo_id, `type`)
)
ENGINE=INNODB;

CREATE TABLE trip_visit (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES user(id),
  trip_place_id INTEGER NOT NULL, /* references nebraska.trip_place */
  user_comment TEXT,
  youtube_video_id VARCHAR(64),
  flickr_photo_id INTEGER DEFAULT NULL,
  FOREIGN KEY (flickr_photo_id) REFERENCES flickr_photo(id)
)
ENGINE=INNODB;