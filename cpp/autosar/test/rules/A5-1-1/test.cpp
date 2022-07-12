#include <iostream>
#include <stdexcept>

void test_exception1() {
  throw "constant string"; // NOT_COMPLIANT - not used in type initialization
}

void test_exception2() {
  throw std::logic_error(
      "constant string"); // COMPLIANT - used in type initialization
}

void test_loop() {
  for (int i = 0; i < 100; i++) { // NON_COMPLIANT - magic constant
  }
  int totalThings =
      100; // COMPLIANT - magic constant used in type initialization
  for (int i = 0; i < totalThings; i++) {
  }
}

void test_stdout() {
  std::cout << "logging string"; // COMPLIANT - literal used in logging
}

class Class1 {
public:
  Class1() : x(0) {} // COMPLIANT - literal used in field initialization
  Class1(int px) : x(px) {}

private:
  int x;
};

class Class2 {
public:
  Class2()
      : Class2(0) {
  } // COMPLIANT - literal used in type initialization through constructor call
  Class2(int px) : x(px) {}

private:
  int x;
};

void test_class() {
  Class1 c;
  Class1 c2(0); // COMPLIANT - literal in type initialization
  Class2 c3;
}

void test_assignment() {
  int x = 0; // COMPLIANT - used in type initialization
  x = 1;     // NON_COMPLIANT - used in assignment
}