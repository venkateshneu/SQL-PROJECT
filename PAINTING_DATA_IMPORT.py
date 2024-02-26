import pandas as pd
from sqlalchemy import create_engine
import urllib.parse

# Encode the special characters in the password
password = urllib.parse.quote_plus('Rajesh@789')

# Construct the connection string
conn_string = f"postgresql://postgres:{password}@localhost/painting_project"

# Create the database engine
db = create_engine(conn_string)

# List of files to import
files = ["artist", "canvas_size", "image_link", "museum_hours", "museum", "product_size", "subject", "work"]

# Import each file into the database
for file in files:
    df = pd.read_csv(f"C:\\Data_Science\\Projects\\SQL PROJECTS\\PAINTING ARTISTS PROJECT\\DATASET\\{file}.csv")
    df.to_sql(file, con=db, if_exists="append", index=False)

# Close the database connection
db.dispose()









