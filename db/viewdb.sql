use roombee; 

-- SELECT * from users;

-- SELECT * from toggles;


UPDATE toggles
SET in_room = 0
WHERE user_id = '80002';
