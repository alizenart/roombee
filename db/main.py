# writing the database functions here!!! yay

import pymysql


# Database connection parameters
host = 'mysql-roombee.cjum622gwom8.us-east-1.rds.amazonaws.com'
user = 'admin'
password = 'roombee1'
database = 'roombee'


def toggle_state_change(user_id, state):
   # Connect to the MySQL database
   connection = pymysql.connect(host=host, user=user, password=password, database=database)
   try:
       with connection.cursor() as cursor:
           # Check the current state
           sql_query = f"SELECT {state} FROM toggles WHERE user_id = %s"
           cursor.execute(sql_query, (user_id,))
           current_value = cursor.fetchone()
          
           if current_value is None:
               print("No such user found.")
               return
          
           # Calculate the new state
           new_value = 0 if current_value[0] else 1
          
           # Update the state
           sql_update = f"UPDATE toggles SET {state} = %s WHERE user_id = %s"
           cursor.execute(sql_update, (new_value, user_id))
           connection.commit()
           print(f"Updated {state} for user_id {user_id} to {new_value}")
  
   finally:
       connection.close()


# Example usage:
toggle_state_change(80002, 'in_room')
#