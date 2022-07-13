#include <stdexcept>

class ClassA {};
class ClassB : std::exception {};

void test_only_stdexception(int i) {
  switch (i) {
  case 0:
    throw ""; // NON_COMPLIANT - literal does not extend std::exception
  case 1:
    throw ClassA(); // NON_COMPLIANT - ClassA does not extends std::exception
  case 2:
    throw ClassB(); // COMPLIANT - extends std::exception
  case 3:
    throw std::exception(); // COMPLIANT - std:exception
  }
}