
use roombee;

-- INSERT INTO events(event_id, user_id, event_title, start_time, end_time, approved) VALUES
--     (1, 1, 'test event 4', '2024-03-20 09:04:05', '2024-03-20 12:17:05', false);

-- SELECT * FROM events;

-- SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'events'

-- ALTER TABLE events
-- ADD COLUMN date DATE NOT NULL DEFAULT (CURRENT_DATE);

-- DELETE FROM events;
-- DELETE FROM events WHERE event_id = 12345;

CREATE TABLE todos
(
  todo_title varchar(64) not null,
  todo_content varchar(128) not null,
  todo_priority varchar(64) not null,
  todo_category varchar(64) not null,
  todo_status TINYINT(1) not null,
  user_id int not NULL,
  hive_code INT not NULL

);

SELECT * FROM todos;