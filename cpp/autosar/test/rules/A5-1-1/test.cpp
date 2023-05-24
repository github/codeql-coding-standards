#include <iostream>
#include <stdexcept>

void test_exception1() {
  throw "constant string"; // NON_COMPLIANT - not used in type initialization
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

void test_stream(std::ostream &os, const char *str) noexcept {
  os << str << "logging string"; // COMPLIANT - literal used in stream write
}

#define WRAPPER_MACRO(X, Y) test_stream(X, Y)

void test_wrapper_stream(std::ostream &os, const char *str) noexcept {
  test_stream(os, "test");   // COMPLIANT - wrapper for stream write
  WRAPPER_MACRO(os, "test"); // COMPLIANT - wrapper for stream write
}

void test_stream_two(std::ostream &os, const char *str,
                     const char *alt) noexcept {
  os << str << "logging string"; // COMPLIANT - literal used in stream write
  throw alt;
}

void test_not_wrapper_stream(std::ostream &os, const char *str) noexcept {
  test_stream_two(os, "test",
                  "not okay"); // NON_COMPLIANT - test_stream_two is
                               // not actually exclusively a wrapper
}

#define MACRO_LOG(test_str)                                                    \
  do {                                                                         \
    struct test_struct {                                                       \
      static const char *get_str() { return static_cast<char *>(test_str); }   \
    };                                                                         \
  } while (false)

void f() {
  MACRO_LOG("test"); // COMPLIANT - exclusion
}