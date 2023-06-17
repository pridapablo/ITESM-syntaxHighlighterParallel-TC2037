# import the necessary modules
import random
import statistics

# define a list of random numbers
numbers = [random.randint(0, 100) for _ in range(20)]

def display_numbers(numbers):
    print(f"The list of numbers: {numbers}")

def compute_average(numbers):
    avg = statistics.mean(numbers)
    print(f"The average of the numbers: {avg}")

def find_max(numbers):
    max_number = max(numbers)
    print(f"The maximum number in the list: {max_number}")

def find_min(numbers):
    min_number = min(numbers)
    print(f"The minimum number in the list: {min_number}")

# driver code
if __name__ == "__main__":
    display_numbers(numbers)
    compute_average(numbers)
    find_max(numbers)
    find_min(numbers)
