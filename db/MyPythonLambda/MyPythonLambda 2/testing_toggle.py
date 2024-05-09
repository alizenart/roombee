import pymysql
import json

def lambda_handler(event, context):
    user_id = event['user_id']
    # Database connection parameters
    host = 'mysql-roombee.cjum622gwom8.us-east-1.rds.amazonaws.com'
    user = 'admin'
    password = 'roombee1'
    database = 'roombee'
    
    def get_toggles(user_id):
        # Connect to the MySQL database
        connection = pymysql.connect(host=host, user=user, password=password, database=database)
        try:
            with connection.cursor() as cursor:
                # Query toggle states for the specified user
                sql_query = "SELECT * FROM toggles WHERE user_id = %s"
                cursor.execute(sql_query, (user_id,))
                toggle_states = cursor.fetchone()
    
                if toggle_states is None:
                    print("No toggle states found for the user.")
                    return None
                else:
                    print("Toggle states received:", toggle_states)
    
                return {
                    'user_id': user_id,
                    'is_sleeping': bool(toggle_states[1]),
                    'in_room': bool(toggle_states[2])
                    # Add more toggle states as needed
                }
        finally:
            connection.close()
    
    return get_toggles(user_id)
