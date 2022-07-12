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