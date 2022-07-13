#include <exception>
#include <stdexcept>
#include <string>

class ClassA : public std::exception {
  // Copy constructor for string is not noexcept
  std::string fieldA;

public:
  ClassA(const char *paramA) : fieldA(paramA) {}
};

struct ClassB : std::runtime_error {
  ClassB(const char *paramA) : std::runtime_error(paramA) {}
};

void test_not_safe() {
  throw ClassA(
      "Exception"); // NON_COMPLIANT - copy constructor is not noexcept(true)
}

void test_safe() {
  throw ClassB("Exception"); // COMPLIANT - copy constructor is noexcept(true)
}