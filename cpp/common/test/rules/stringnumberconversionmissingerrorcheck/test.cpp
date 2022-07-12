#include <iomanip>
#include <iostream>
#include <istream>
#include <sstream>

void test_missing_error_check() {
  std::basic_istream<char> s(0);
  int x;
  s >> x; // NON_COMPLIANT
}

void test_missing_error_check_chained() {
  std::basic_istream<char> s(0);
  int x;
  s >> std::hex >> std::setw(4) >> x; // NON_COMPLIANT
}

void test_correct_error_check() {
  std::basic_istream<char> s(0);
  int x;
  s >> x; // COMPLIANT
  if (s.fail()) {
    throw "error";
  }
}

void test_correct_good_check() {
  std::basic_istream<char> s(0);
  int x;
  s >> x; // COMPLIANT
  if (s.good()) {
    // Continues...
  } else {
    throw "error";
  }
}

void test_correct_error_check_chained() {
  std::basic_istream<char> s(0);
  int x;
  s >> std::hex >> std::setw(4) >> x; // COMPLIANT
  if (s.fail()) {
    throw "error";
  }
}

void test_correct_exceptions() {
  std::basic_istream<char> s(0);
  s.exceptions(std::istream::failbit | std::istream::badbit);
  int x;
  s >> x; // COMPLIANT - will throw an exceptions
}

void test_incomplete_exceptions_non_compliant() {
  std::basic_istream<char> s(0);
  s.exceptions(std::istream::badbit); // incomplete
  int x;
  s >> x; // NON_COMPLIANT - badbit is not sufficient alone
}

void test_exceptions_but_after() {
  std::basic_istream<char> s(0);
  int x;
  s >> x; // COMPLIANT - will throw an exception on `exceptions` below
  // exceptions will cause an exception to be thrown if any of the failbits are
  // already set
  s.exceptions(std::istream::failbit | std::istream::badbit);
}

void test_negation_compliant() {
  std::basic_istream<char> s(0);
  int x;
  if (!(s >> x)) { // COMPLIANT
    throw "error";
  }
}

void test_boolean_conversion_compliant() {
  std::basic_istream<char> s(0);
  int x;
  if (s >> x) { // COMPLIANT
  } else {
    throw "error";
  }
}

void test_cin_compliant() {
  int x;
  // std::cin is an extern-ed global variable, with no initializer, so ensure
  // we match up consecutive uses
  std::cin >> x; // COMPLIANT
  if (std::cin.fail()) {
    throw "error";
  }
}

void test_cin_compliant_exceptions() {
  std::cin.exceptions(std::istream::failbit | std::istream::badbit);
  int x;
  std::cin >> x; // COMPLIANT
}

void test_cin_non_compliant() {
  int x;
  std::cin >> x; // NON_COMPLIANT
}

std::basic_istream<char> s2(0);

void test_global_compliant() {
  int x;
  s2 >> x; // NON_COMPLIANT
}

void test_global_non_compliant() {
  int x;
  s2 >> x; // COMPLIANT
  if (s2.fail()) {
    throw "error";
  }
}

void init_stream(std::basic_istream<char> &s) {
  s.exceptions(std::istream::failbit | std::istream::badbit);
}

void readInt(std::basic_istream<char> &s) {
  int x;
  s >> x; // COMPLIANT - all sources have exceptions enabled
}

void readInt2(std::basic_istream<char> &s) {
  int x;
  s >> x; // NON_COMPLIANT - one source is not exceptions compliant
}

void test_non_local_exceptions_enabled_compliant() {
  std::basic_istream<char> s(0);
  init_stream(s);
  int x;
  s >> x; // COMPLIANT - throws an exception
  std::basic_istream<char> s1(0);
  init_stream(s1);
  readInt(s1);
  readInt2(s1);
}

void test_non_local_exceptions_enabled_non_compliant() {
  std::basic_istream<char> s(0);
  readInt2(s); // This triggers non compliant behavior in readInt2
               // as exceptions are not enabled in this code path
}

void handle_error(std::basic_istream<char> &s) {
  if (s.fail()) {
    throw "error";
  }
}

void test_non_local_fail_check() {
  std::basic_istream<char> s(0);
  int x;
  s >> x; // COMPLIANT - checked below
  handle_error(s);
}

class Base {
public:
  int read_non_compliant();
  int readHex_non_compliant();
  int read_compliant();
  int readHex_compliant();

private:
  std::basic_istream<char> f1;
};

int Base::read_non_compliant() {
  int x;
  f1 >> x; // NON_COMPLIANT
  return x;
}

int Base::readHex_non_compliant() {
  int x;
  f1 >> std::hex >> std::setw(4) >> x; // NON_COMPLIANT
  return x;
}

int Base::read_compliant() {
  int x;
  f1 >> x; // COMPLIANT
  if (f1.fail()) {
    throw "error";
  }
  return x;
}

int Base::readHex_compliant() {
  int x;
  f1 >> std::hex >> std::setw(4) >> x; // COMPLIANT
  if (f1.fail()) {
    throw "error";
  }
  return x;
}

class ClassA {
public:
  ClassA() : f1(0) {
    init(); // Constructor calls a function which sets exceptions flags
  }
  int read() {
    int x;
    f1 >> x; // COMPLIANT - throws an exception on fail
    return x;
  }
  void init() { enable_exceptions(); }
  void enable_exceptions() {
    f1.exceptions(std::istream::failbit | std::istream::badbit);
  }

private:
  std::basic_istream<char> f1;
};