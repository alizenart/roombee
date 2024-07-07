USE roombee; 

-- DROP TABLE events;

CREATE TABLE events
(
  event_id int not null,
  user_id int not null, 
  event_title VARCHAR(255),
  start_time TIME not null, 
  end_time TIME not null, 
  approved BOOL
);
