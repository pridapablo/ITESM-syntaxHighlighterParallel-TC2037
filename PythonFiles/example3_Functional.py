import json
from functools import reduce

# List of dictionaries
data = [
    {"name": "Alice", "age": 25, "city": "New York"},
    {"name": "Bob", "age": 30, "city": "Chicago"},
    {"name": "Charlie", "age": 35, "city": "San Francisco"},
]

# Convert list into JSON
json_data = json.dumps(data)
print(f"JSON data: {json_data}")

# Load data from JSON
loaded_data = json.loads(json_data)

# Use map() to get all names
names = list(map(lambda x: x['name'], loaded_data))
print(f"Names: {names}")

# Use filter() to get data of people older than 30
older_than_30 = list(filter(lambda x: x['age'] > 30, loaded_data))
print(f"People older than 30: {older_than_30}")

# Use reduce() to find the longest name
longest_name = reduce(lambda a, b: a if len(a['name']) > len(b['name']) else b, loaded_data)
print(f"Person with the longest name: {longest_name['name']}")
