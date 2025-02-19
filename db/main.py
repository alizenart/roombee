# writing the database functions here!!! yay

import pymysql
import csv

# Database connection
connection = pymysql.connect(
    host = 'mysql-roombee.cjum622gwom8.us-east-1.rds.amazonaws.com',
    user = 'admin',
    password = 'roombee1',
    database = 'roombee'
)

try:
    with connection.cursor() as cursor:
        # Query to fetch data
        cursor.execute("SELECT * FROM users ORDER BY email ASC")
        rows = cursor.fetchall()
        headers = [desc[0] for desc in cursor.description]

        # Save data to CSV
        with open('users.csv', 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(headers)  # Write column headers
            writer.writerows(rows)    # Write rows of data

        print("Data exported to users.csv")
finally:
    connection.close()
