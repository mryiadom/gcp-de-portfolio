# Week 11 scratch file: code along with the videos here.
# This is for experiments; the finished Ticker class goes in src/ticker.py.
'''
- A class is a blueprint
- Each object/ instance from a class is a seperate thing
'''
import csv
from pathlib import Path

CSV_PATH = Path(__file__).parent / 'items.csv'

class Item:
    pay_rate = 0.8 # 20% discount

    all = []

    def __init__(self, name: str, price: float, quantity=0):
       # Run validations to received arguments
        assert price >= 0, f"Price can't be less than {price}"
        assert quantity >= 0, f"Price can't be less than {quantity}"
       
       # Assign to self object
        self.name = name
        self.price = price
        self.quantity = quantity

        Item.all.append(self)

    def calculate_total_price(self):
        return self.price * self.quantity

    def apply_discount(self):
        self.price = self.price * self.pay_rate
        return self.price

    @classmethod
    def instantiate_from_csv(cls):
        with open(CSV_PATH, 'r') as f:
            reader = csv.DictReader(f)
            items = list(reader)

        for item in items:
            Item(
                name= item['name'],
                price= float(item['price']),
                quantity= int(item['quantity']),
            )

    def __repr__(self):
        return f"Item('{self.name}', {self.price}, {self.quantity})"

Item.instantiate_from_csv()
print(Item.all)


'''
class Dog:                                   # CLASS: the blueprint
    species = "Canis familiaris"             # CLASS ATTRIBUTE: one copy, shared by all dogs
    count = 0                                # CLASS ATTRIBUTE: a shared counter

    def __init__(self, name, age):           # __init__: runs when an object is created
        self.name = name                     # INSTANCE ATTRIBUTE: each dog has its own
        self.age = age
        Dog.count += 1                       # changes the shared class attribute

    def speak(self):                         # INSTANCE METHOD: works on ONE dog (self)
        return f"{self.name} says woof"

    @property                                # PROPERTY: a method that reads like an attribute
    def is_puppy(self):
        return self.age < 2

    @classmethod                             # CLASS METHOD: works on the CLASS (cls)
    def how_many(cls):
        return f"{cls.count} dogs exist"

    @classmethod                             # common use: an alternative way to BUILD an object
    def from_string(cls, text):
        name, age = text.split(",")
        return cls(name, int(age))

    @staticmethod                            # STATIC METHOD: no self, no cls; just a helper
    def dog_years(human_years):
        return human_years * 7

    def __repr__(self):                      # DUNDER METHOD: how the object describes itself
        return f"Dog('{self.name}', {self.age})"

rex = Dog("Rex", 4)                          # OBJECT (also called an INSTANCE)
fido = Dog("Fido", 1)
bella = Dog.from_string("Bella,3")


'''

'''
THE DIFFERENCES SIDE BY SIDE

term                    what it is                                it receives  works on         called like
----------------------  ----------------------------------------  -----------  ---------------  -------------------
class                   the blueprint                                                           class Dog:
object / instance       one thing built from it                                                 rex = Dog(...)
instance attribute      data belonging to ONE object                           one object       rex.name
class attribute         data shared by ALL objects                             the class        Dog.species
instance method         a function on one object                  self         one object       rex.speak()
class method            a function on the class itself            cls          the class        Dog.how_many()
static method           a plain helper that lives in the class    nothing      neither          Dog.dog_years(3)
property                a method that reads like an attribute     self         one object       rex.is_puppy
__init__                runs when an object is created            self         the new object   automatic
dunder method           built-in hook Python calls for you        self         one object       automatic (__repr__)

WHICH ONE DO I NEED?
- Does it need to know about one particular dog?      -> instance method (uses self)
- Does it need the class but no single dog?           -> class method (uses cls), e.g. counting
                                                         dogs, or building one from text
- Does it need neither?                               -> static method (just a tidy function)

WHAT THE DOG EXAMPLE PRINTS (add the print lines yourself to check)
instance attribute : Rex | Fido                          <- differ per object
class attribute    : Canis familiaris | Canis familiaris <- same for all
instance method    : Rex says woof
property           : False | True                        <- no brackets needed
class method       : 3 dogs exist
static method      : 21
repr               : Dog('Rex', 4)
built from a string: Dog('Bella', 3)
after changing fido.name       : Rex | Fido II           <- only fido changed
after changing Dog.species     : Wolf | Wolf             <- everyone changed

WHERE EACH ONE SHOWS UP IN THIS WEEK
- Tuesday exercise 4 (count Ticker objects)  -> a class attribute, like Dog.count
- Tuesday exercise 5 (.is_tech)              -> a property, like is_puppy
- Thursday (__repr__ and __eq__ on Ticker)   -> dunder methods
- Item above uses a class attribute (all, pay_rate), an instance method
  (apply_discount) and a class method (instantiate_from_csv)
'''