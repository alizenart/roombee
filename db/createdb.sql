-- CREATE DATABASE roombee;  
USE roombee; 

CREATE TABLE users
(
  user_id int not null AUTO_INCREMENT, -- auto increment = value will be autogen by db when new record is inserted 
  email varchar(128) not null, 
  last_name varchar(64) not null, 
  first_name varchar(64) not null, 
  dob DATE not null,
  hive_code int not null, 
  password_hash CHAR(64) not null, -- store as hash, hash in api.
  PRIMARY KEY (user_id), 
  UNIQUE (email)
);

ALTER TABLE users AUTO_INCREMENT = 80001; -- starting value 


CREATE TABLE events
(
  user_id int not null, 
  event_title VARCHAR(255),
  event_date DATE not null, 
  start_time TIME not null, 
  end_time TIME not null, 
  approved BOOL
);

CREATE TABLE toggles 
(
  user_id int not null, 
  in_room BOOL DEFAULT 0, 
  is_sleeping BOOL DEFAULT 0
);

CREATE TABLE hives
(
  hive_code int not null AUTO_INCREMENT, 
  num_of_residents int not null, -- best way to map multiple users to one hive? 
  room_location varchar(128) not null, 
  admin_id int, -- add RA?
  floor int, 
  dorm varchar(128), 
  university varchar(128),
  PRIMARY KEY (hive_code)
);
