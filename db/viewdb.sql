use roombee; 

-- SELECT * from users;

SELECT * from toggles;

'''
UPDATE toggles
SET in_room = 1
WHERE user_id = '80003';
'''