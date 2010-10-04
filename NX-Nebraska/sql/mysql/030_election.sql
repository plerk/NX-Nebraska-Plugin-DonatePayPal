/* 
 * election schema for NX::Nebraska
 * MySQL
 */

DROP TABLE IF EXISTS us_election_vote;
DROP TABLE IF EXISTS us_election_state_max;
DROP TABLE IF EXISTS us_election_state;
DROP TABLE IF EXISTS us_election_candidate;
DROP TABLE IF EXISTS us_election_party;
DROP TABLE IF EXISTS us_election;
 
CREATE TABLE us_election (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  `year` INTEGER,
  `map` INTEGER,
  `type` ENUM('president', 'senate', 'house'),
  UNIQUE (`year`, `type`)
);

INSERT INTO us_election (year, map, type) VALUES (2012, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (2008, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (2004, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (2000, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (1996, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (1992, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (1988, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (1984, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (1980, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (1976, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (1972, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (1968, 1964, 'president');
INSERT INTO us_election (year, map, type) VALUES (1964, 1964, 'president');

INSERT INTO us_election (year, map, type) VALUES (1960, 1960, 'president');

INSERT INTO us_election (year, map, type) VALUES (1956, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1952, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1948, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1944, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1940, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1936, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1932, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1928, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1924, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1920, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1916, 1912, 'president');
INSERT INTO us_election (year, map, type) VALUES (1912, 1912, 'president');

INSERT INTO us_election (year, map, type) VALUES (1908, 1908, 'president');

INSERT INTO us_election (year, map, type) VALUES (1904, 1896, 'president');
INSERT INTO us_election (year, map, type) VALUES (1900, 1896, 'president');
INSERT INTO us_election (year, map, type) VALUES (1896, 1896, 'president');

INSERT INTO us_election (year, map, type) VALUES (1892, 1892, 'president');

INSERT INTO us_election (year, map, type) VALUES (1888, 1876, 'president');
INSERT INTO us_election (year, map, type) VALUES (1884, 1876, 'president');
INSERT INTO us_election (year, map, type) VALUES (1880, 1876, 'president');
INSERT INTO us_election (year, map, type) VALUES (1876, 1876, 'president');

INSERT INTO us_election (year, map, type) VALUES (1872, 1868, 'president');
INSERT INTO us_election (year, map, type) VALUES (1868, 1868, 'president');

INSERT INTO us_election (year, map, type) VALUES (1864, 1864, 'president');

INSERT INTO us_election (year, map, type) VALUES (1860, 1860, 'president');

INSERT INTO us_election (year, map, type) VALUES (1856, 1852, 'president');
INSERT INTO us_election (year, map, type) VALUES (1852, 1852, 'president');

INSERT INTO us_election (year, map, type) VALUES (1848, 1848, 'president');

INSERT INTO us_election (year, map, type) VALUES (1844, 1836, 'president');
INSERT INTO us_election (year, map, type) VALUES (1840, 1836, 'president');
INSERT INTO us_election (year, map, type) VALUES (1836, 1836, 'president');

INSERT INTO us_election (year, map, type) VALUES (1832, 1820, 'president');
INSERT INTO us_election (year, map, type) VALUES (1828, 1820, 'president');
INSERT INTO us_election (year, map, type) VALUES (1824, 1820, 'president');
INSERT INTO us_election (year, map, type) VALUES (1820, 1820, 'president');

INSERT INTO us_election (year, map, type) VALUES (1816, 1812, 'president');
INSERT INTO us_election (year, map, type) VALUES (1812, 1812, 'president');

INSERT INTO us_election (year, map, type) VALUES (1808, 1804, 'president');
INSERT INTO us_election (year, map, type) VALUES (1804, 1804, 'president');

INSERT INTO us_election (year, map, type) VALUES (1800, 1796, 'president');
INSERT INTO us_election (year, map, type) VALUES (1696, 1796, 'president');

INSERT INTO us_election (year, map, type) VALUES (1792, 1792, 'president');

INSERT INTO us_election (year, map, type) VALUES (1789, 1788, 'president');

/*
 * +-----+---------------------------------+-------+
 * | id  | name                            | count |
 * +-----+---------------------------------+-------+
 * | DIX | States' Rights Democratic Party |     1 |
 * | CUP | Constitutional Union Party      |     1 |
 * | IND | American Independent Party      |     1 |
 * | KNP | Know-Nothing                    |     1 |
 * | REF | Reform Party                    |     1 |
 * | LIB | Liberal Republican Party        |     1 |
 * | AMP | Anti-Masonic Party              |     1 |
 * | POP | Populist Party                  |     1 |
 * | NDP | Northern Democratic Party       |     1 |
 * | SDP | Southern Democratic Party       |     1 |
 * | FSP | Free Soil Party                 |     1 |
 * | NRP | National Republican Party       |     2 |
 * | PRO | Progressive Party               |     2 |
 * | WHG | Whig Party                      |     4 |
 * | FED | Federalist Party                |     4 |
 * | DRP | Democratic-Republican Party     |     4 |
 * | GOP | Republican Party                |    26 |
 * | DEM | Democratic Party                |    31 |
 * +-----+---------------------------------+-------+
 */

CREATE TABLE us_election_party (
  id CHAR(3) PRIMARY KEY,
  name VARCHAR(64),
  color INTEGER NOT NULL
);

INSERT INTO us_election_party (id, name, color) VALUES ('GOP', 'Republican Party', 16711680);
INSERT INTO us_election_party (id, name, color) VALUES ('DEM', 'Democratic Party', 255);
INSERT INTO us_election_party (id, name, color) VALUES ('REF', 'Reform Party',0);
INSERT INTO us_election_party (id, name, color) VALUES ('IND', 'American Independent Party',0);
INSERT INTO us_election_party (id, name, color) VALUES ('DIX', 'States\' Rights Democratic Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('PRO', 'Progressive Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('POP', 'Populist Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('LIB', 'Liberal Republican Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('KNP', 'Know-Nothing', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('WHG', 'Whig Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('FSP', 'Free Soil Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('NRP', 'National Republican Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('AMP', 'Anti-Masonic Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('DRP', 'Democratic-Republican Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('FED', 'Federalist Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('CUP', 'Constitutional Union Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('SDP', 'Southern Democratic Party', 0);
INSERT INTO us_election_party (id, name, color) VALUES ('NDP', 'Northern Democratic Party', 0);

/*
 * +--------------------+-------+
 * | name               | count |
 * +--------------------+-------+
 * | Andrew Jackson     |     2 |
 * | Henry Clay         |     3 |
 * | John Quincy Adams  |     2 |
 * | Martin Van Buren   |     2 |
 * | Ross Perot         |     2 |
 * | Theodore Roosevelt |     2 |
 * +--------------------+-------+
 */

CREATE TABLE us_election_candidate (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  us_election_party_id CHAR(3),
  FOREIGN KEY (us_election_party_id) REFERENCES us_election_party(id),
  name VARCHAR(64),
  UNIQUE (us_election_party_id, name)
);

INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('John McCain',           'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Barack Obama',          'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('George W. Bush',        'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('John Kerry',            'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Al Gore',               'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Bill Clinton',          'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Bob Dole',              'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Ross Perot',            'REF');
INSERT INTO us_election_candidate (name) VALUES ('Ross Perot');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('George H. W. Bush',     'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Michael Dukakis',       'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Ronald Reagan',         'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Walter Mondale',        'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Jimmy Carter',          'DEM');
INSERT INTO us_election_candidate (name) VALUES ('John B. Anderson');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Gerald Ford',           'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Richard Nixon',         'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('George McGovern',       'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Hubert Humphrey',       'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('George Wallace',        'IND');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Lyndon B. Johnson',     'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Barry Goldwater',       'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('John F. Kennedy',       'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Dwight D. Eisenhower',  'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Adlai Stevenson',       'DEM');
INSERT INTO us_election_candidate (name) VALUES ('Walter Burgwyn Jones');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Harry S. Truman',       'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Thomas E. Dewey',       'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Strom Thurmond',        'DIX');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Franklin D. Roosevelt', 'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Wendell Willkie',       'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Alf Landon',            'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Herbert Hoover',        'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Al Smith',              'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Calvin Coolidge',       'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('John W. Davis',         'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Robert M. La Follette, Sr.','PRO');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Warren G. Harding',     'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('James M. Cox',          'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Woodrow Wilson',        'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Charles Evans Hughes',  'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Theodore Roosevelt',    'PRO');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('William Howard Taft',   'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('William Jennings Bryan','DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Theodore Roosevelt',    'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Alton B. Parker',       'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('William McKinley',      'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Grover Cleveland',      'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Benjamin Harrison',     'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('James Weaver',          'POP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('James G. Blaine',       'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('James Garfield',        'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Winfield Hancock',      'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Rutherford B. Hayes',   'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Samuel J. Tilden',      'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Ulysses S. Grant',      'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Horace Greeley',        'LIB');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Horatio Seymour',       'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('George B. McClellan',   'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Abraham Lincoln',       'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('John Bell',             'CUP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('John C. Breckinridge',  'SDP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Stephen A. Douglas',    'NDP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('James Buchanan',        'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('John C. Frémont',       'GOP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Millard Fillmore',      'KNP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Franklin Pierce',       'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Winfield Scott',        'WHG');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Zachary Taylor',        'WHG');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Lewis Cass',            'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Martin Van Buren',      'FSP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('James K. Polk',         'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Henry Clay',            'WHG');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('William Henry Harrison','WHG');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Martin Van Buren',      'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Andrew Jackson',        'DEM');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Henry Clay',            'NRP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('William Wirt',          'AMP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('John Quincy Adams',     'NRP');
INSERT INTO us_election_candidate (name) VALUES ('John Quincy Adams');
INSERT INTO us_election_candidate (name) VALUES ('Andrew Jackson');
INSERT INTO us_election_candidate (name) VALUES ('Henry Clay');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('William H. Crawford',   'DRP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('James Monroe',          'DRP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Rufus King',            'FED');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('James Madison',         'DRP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('DeWitt Clinton',        'FED');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Charles Cotesworth Pinckney', 'FED');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('Thomas Jefferson',      'DRP');
INSERT INTO us_election_candidate (name,us_election_party_id) VALUES ('John Adams',            'FED');
INSERT INTO us_election_candidate (name) VALUES ('George Washington');

CREATE TABLE us_election_state (
  id CHAR(2) PRIMARY KEY,
  name VARCHAR(64)
);

INSERT INTO us_election_state (id, name) VALUES ('AL','Alabama');
INSERT INTO us_election_state (id, name) VALUES ('AK','Alaska');
INSERT INTO us_election_state (id, name) VALUES ('AZ','Arizona');
INSERT INTO us_election_state (id, name) VALUES ('AR','Arkansas');
INSERT INTO us_election_state (id, name) VALUES ('CA','California');
INSERT INTO us_election_state (id, name) VALUES ('CO','Colorado');
INSERT INTO us_election_state (id, name) VALUES ('CT','Connecticut');
INSERT INTO us_election_state (id, name) VALUES ('DE','Delaware');
INSERT INTO us_election_state (id, name) VALUES ('DC','District of Columbia');
INSERT INTO us_election_state (id, name) VALUES ('FL','Florida');
INSERT INTO us_election_state (id, name) VALUES ('GA','Georgia');
INSERT INTO us_election_state (id, name) VALUES ('HI','Hawaii');
INSERT INTO us_election_state (id, name) VALUES ('ID','Idaho');
INSERT INTO us_election_state (id, name) VALUES ('IL','Illinois');
INSERT INTO us_election_state (id, name) VALUES ('IN','Indiana');
INSERT INTO us_election_state (id, name) VALUES ('IA','Iowa');
INSERT INTO us_election_state (id, name) VALUES ('KS','Kansas');
INSERT INTO us_election_state (id, name) VALUES ('KY','Kentucky');
INSERT INTO us_election_state (id, name) VALUES ('LA','Louisiana');
INSERT INTO us_election_state (id, name) VALUES ('ME','Maine');
INSERT INTO us_election_state (id, name) VALUES ('MD','Maryland');
INSERT INTO us_election_state (id, name) VALUES ('MA','Massachusetts');
INSERT INTO us_election_state (id, name) VALUES ('MI','Michigan');
INSERT INTO us_election_state (id, name) VALUES ('MN','Minnesota');
INSERT INTO us_election_state (id, name) VALUES ('MS','Mississippi');
INSERT INTO us_election_state (id, name) VALUES ('MO','Missouri');
INSERT INTO us_election_state (id, name) VALUES ('MT','Montana');
INSERT INTO us_election_state (id, name) VALUES ('NE','Nebraska');
INSERT INTO us_election_state (id, name) VALUES ('NV','Nevada');
INSERT INTO us_election_state (id, name) VALUES ('NH','New Hampshire');
INSERT INTO us_election_state (id, name) VALUES ('NJ','New Jersey');
INSERT INTO us_election_state (id, name) VALUES ('NM','New Mexico');
INSERT INTO us_election_state (id, name) VALUES ('NY','New York');
INSERT INTO us_election_state (id, name) VALUES ('NC','North Carolina');
INSERT INTO us_election_state (id, name) VALUES ('ND','North Dakota');
INSERT INTO us_election_state (id, name) VALUES ('OH','Ohio');
INSERT INTO us_election_state (id, name) VALUES ('OK','Oklahoma');
INSERT INTO us_election_state (id, name) VALUES ('OR','Oregon');
INSERT INTO us_election_state (id, name) VALUES ('PA','Pennsylvania');
INSERT INTO us_election_state (id, name) VALUES ('RI','Rhode Island');
INSERT INTO us_election_state (id, name) VALUES ('SC','South Carolina');
INSERT INTO us_election_state (id, name) VALUES ('SD','South Dakota');
INSERT INTO us_election_state (id, name) VALUES ('TN','Tennessee');
INSERT INTO us_election_state (id, name) VALUES ('TX','Texas');
INSERT INTO us_election_state (id, name) VALUES ('UT','Utah');
INSERT INTO us_election_state (id, name) VALUES ('VT','Vermont');
INSERT INTO us_election_state (id, name) VALUES ('VA','Virginia');
INSERT INTO us_election_state (id, name) VALUES ('WA','Washington');
INSERT INTO us_election_state (id, name) VALUES ('WV','West Virginia');
INSERT INTO us_election_state (id, name) VALUES ('WI','Wisconsin');
INSERT INTO us_election_state (id, name) VALUES ('WY','Wyoming');

CREATE TABLE us_election_state_max (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  us_election_state_id CHAR(2) NOT NULL,
  `year` INTEGER NOT NULL,
  UNIQUE (us_election_state_id, `year`),
  `count` INTEGER NOT NULL
);

INSERT INTO us_election_state_max (us_election_state_id, `year`, `count`) VALUES ('AZ', 2008, 10);
INSERT INTO us_election_state_max (us_election_state_id, `year`, `count`) VALUES ('IL', 2008, 21);

CREATE TABLE us_election_vote (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  us_election_id INTEGER NOT NULL,
  FOREIGN KEY (us_election_id) REFERENCES us_election(id),
  us_election_state_id CHAR(2) NOT NULL,
  FOREIGN KEY (us_election_state_id) REFERENCES us_election_state(id),
  us_election_candidate_id INTEGER NOT NULL,
  FOREIGN KEY (us_election_candidate_id) REFERENCES us_election_candidate(id),
  `count` INTEGER NOT NULL
);

INSERT INTO us_election_vote (us_election_id, us_election_state_id, us_election_candidate_id, `count`)
VALUES (2, 'AZ', 1, 10);
INSERT INTO us_election_vote (us_election_id, us_election_state_id, us_election_candidate_id, `count`)
VALUES (2, 'IL', 2, 21);