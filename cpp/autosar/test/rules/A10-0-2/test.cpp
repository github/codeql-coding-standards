class Animal {};
class AnimalCollection {};
class Dog : public Animal {};
class Zoo : public AnimalCollection {};
class Device {};
class CPU {};
class Printer1 : private CPU {};
class Printer2 : private Device {};
class Printer3 : public Device {};