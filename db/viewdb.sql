use roombee;

-- INSERT INTO events(event_id, user_id, event_title, start_time, end_time, approved) VALUES
--     (1, 1, 'test event 4', '2024-03-20 09:04:05', '2024-03-20 12:17:05', false);

-- SELECT * FROM events;

-- SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'events'

-- ALTER TABLE events
-- ADD COLUMN date DATE NOT NULL DEFAULT (CURRENT_DATE);

-- DELETE FROM events;
-- DELETE FROM events WHERE event_id = 12345;

SELECT * FROM users;
