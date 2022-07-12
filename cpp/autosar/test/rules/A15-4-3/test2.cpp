#include <stdexcept>

void test_noexcept_true_no_exception(); // NON_COMPLIANT

void test_noexcept_true_exception() noexcept(
    true); // NON_COMPLIANT - definition throws an exception

void test_noexcept_inconsistent(); // NON_COMPLIANT

class ClassA {
  virtual void methodA(); // NON_COMPLIANT - inconsistent with test.cpp
  virtual void methodB(); // NON_COMPLIANT - inconsistent with test.cpp
  virtual void methodC();
};

class ClassB : ClassA {
  void methodA() { // NON_COMPLIANT - overrides noexcept(true) virtual method
  }
  virtual void methodB() noexcept(true); // COMPLIANT
  virtual void methodC() noexcept(true); // COMPLIANT - can be more restrictive
};