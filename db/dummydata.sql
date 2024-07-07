use roombee;

INSERT INTO 
  users(email, last_name, first_name, dob, hive_code, password_hash)
  values('roombeeapp.gmail.com', 'bee', 'room', '2024-04-16', 0, 'asldkfalskdflaskdf');

INSERT INTO 
  users(email, last_name, first_name, dob, hive_code, password_hash)
  values('fakeroommate1', 'one', 'roommate1', '2024-04-16', 1, 'abc123');

INSERT INTO 
  users(email, last_name, first_name, dob, hive_code, password_hash)
  values('fakeroommate2', 'two', 'roommate2', '2024-04-16', 1, 'def234');

INSERT INTO 
  toggles(user_id, in_room, is_sleeping)
  values('80002', '0', '0')

INSERT INTO 
  toggles(user_id, in_room, is_sleeping)
  values('80003', '0', '0')

