import random

class Restaurant:
    def __init__(self, name, capacity):
        self.name = name
        self.capacity = capacity
        self.reservations = []

    def reserve(self, party_size):
        if self.available_seats() < party_size:
            return False
        else:
            self.reservations.append(party_size)
            return True

    def available_seats(self):
        return self.capacity - sum(self.reservations)


class Customer:
    def __init__(self, name):
        self.name = name

    def make_reservation(self, restaurant, party_size):
        if restaurant.reserve(party_size):
            print(f"Reservation for {self.name} at {restaurant.name} confirmed!")
        else:
            print(f"Sorry, {self.name}. No available space at {restaurant.name}.")


if __name__ == "__main__":
    # Restaurants
    taco_joint = Restaurant("Taco Joint", 50)
    sushi_spot = Restaurant("Sushi Spot", 75)

    # Customers
    alice = Customer("Alice")
    bob = Customer("Bob")

    # Attempt to make reservations
    alice.make_reservation(taco_joint, 20)
    bob.make_reservation(sushi_spot, 80)
