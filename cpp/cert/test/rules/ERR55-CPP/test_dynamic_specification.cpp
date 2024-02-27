#include <exception>
#include <stdexcept>

void test_no_exception_spec() { // COMPLIANT - no dynamic exception
                                // specification
  throw std::exception();
}

void throw_logic_error() { throw std::logic_error("Error"); }

void test_simple_exception_spec_covered(int i) // COMPLIANT
    throw(std::exception) {
  if (i < 0) {
    throw std::exception();
  } else {
    throw_logic_error();
  }
}

void test_simple_exception_spec_covered_inherited() // NON_COMPLIANT
    throw(std::logic_error) { // exception is not a sub-class of logic_error
  throw std::exception();
}

void test_no_throw() throw() { // COMPLIANT
}

void test_no_throw_contravened() throw() { // NON_COMPLIANT
  throw std::exception();
}

class DummyException {};
void indirect_throw_logic_error() throw(std::logic_error) {
  throw_logic_error(); // Exception flows out of function as specification is
                       // compatible
}
void indirect_throw_logic_error_but_terminates() throw() { // NON_COMPLIANT
  throw_logic_error(); // Exception does not flow out of function due to
                       // specification
}
void indirect_throw_logic_error_but_terminates_2() // NON_COMPLIANT
    throw(DummyException) {
  throw_logic_error(); // Exception does not flow out of function due to
                       // specification
}

void test_indirect_throws() throw() { // NON_COMPLIANT
  indirect_throw_logic_error();
}

void test_indirect_throws_but_terminated() throw() { // COMPLIANT
  indirect_throw_logic_error_but_terminates();
  indirect_throw_logic_error_but_terminates_2();
}