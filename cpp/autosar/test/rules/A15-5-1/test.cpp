#include "stddef.h"
#include <stdexcept>

class ClassA {
  ~ClassA() noexcept(false) { throw std::exception(); } // NON_COMPLIANT
};

class ClassB {
  ~ClassB() noexcept(false) // NON_COMPLIANT
      try {
    throw std::exception();
  } catch (...) {
  } // Exceptions will be rethrown at the end of the function-try-catch
};

class ClassB2 {
  ~ClassB2() // COMPLIANT
      try {
    throw std::exception();
  } catch (...) {
    return; // Execution doesn't reach end of the function-try-catch, so
  }         // exception is not rethrown
};

class ClassC {
  ~ClassC() {} // COMPLIANT
};

class ClassD {
  ~ClassD() // COMPLIANT - exception does not escape
      try {
    throw std::exception();
  } catch (...) {
    return;
  }
};

void operator delete(void *ptr) { // NON_COMPLIANT
  // NOTE: cannot be declared noexcept(false)
  throw std::exception();
}

void operator delete(void *ptr, size_t size) { // NON_COMPLIANT
  // NOTE: cannot be declared noexcept(false)
  throw std::exception();
}

class ClassE {
  ClassE &operator=(ClassE &&rhs) noexcept(true) { return *this; } // COMPLIANT
};

class ClassF {
  ClassF &operator=(ClassF &&rhs) noexcept(false) { // NON_COMPLIANT
    throw std::exception();
  }
};

class ClassG {
  ClassG(ClassG &&rhs) noexcept(true) {} // COMPLIANT
};

class ClassH {
  ClassH(ClassH &&rhs) noexcept(false) { // NON_COMPLIANT
    throw std::exception();
  }
};

void swap(ClassA &lhs, ClassA &rhs){
    // NON_COMPLIANT
};

void swap(ClassB &lhs, ClassB &rhs) noexcept(false) { // NON_COMPLIANT
  throw std::exception();
};

class ClassI {
  void swap(ClassI &rhs) { // NON_COMPLIANT
  }
};

class ClassJ {
  void swap(ClassJ &rhs) { // NON_COMPLIANT
    throw std::exception();
  }
};

template <typename T0, typename T1>
void swap(T0 &lhs, T1 &rhs) { // NON_COMPLIANT
  throw std::exception();
}

class ClassK {};

void test_swap_template() {
  ClassK k1;
  ClassK k2;
  swap(k1, k2); // Used to instantiate the exception throwing template above
}