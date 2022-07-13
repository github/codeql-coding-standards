#include <stdexcept>

class ExceptionA : std::exception {};
class ExceptionB : std::exception {};
class ExceptionC : std::exception {};

void throwA() { throw ExceptionA(); }

void throwB() { throw ExceptionB(); }

void throwC() { throw ExceptionC(); }

void throwBOrA() {
  throwA();
  throwB();
}

void test_thrown_exceptions() {
  throwBOrA();
  throwC();
}