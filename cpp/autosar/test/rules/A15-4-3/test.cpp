#include <stdexcept>

void test_noexcept_true_no_exception() noexcept(true) {}

void test_noexcept_true_exception() { throw std::exception(); }

void test_noexcept_inconsistent() noexcept(true);

class ClassA {
  virtual void methodA() noexcept(true);
  virtual void methodB() noexcept(true);
  virtual void methodC();
};