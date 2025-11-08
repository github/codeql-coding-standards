#include "csetjmp"  // NON_COMPLIANT
#include "setjmp.h" // NON_COMPLIANT
#include <csetjmp>  // NON_COMPLIANT
#include <setjmp.h> // NON_COMPLIANT
#include <stdexcept>

// Global variables for testing
jmp_buf g1;      // NON_COMPLIANT
std::jmp_buf g2; // NON_COMPLIANT

void test_setjmp_usage() {
  jmp_buf l1;            // NON_COMPLIANT
  if (setjmp(l1) == 0) { // NON_COMPLIANT
    longjmp(l1, 1);      // NON_COMPLIANT
  }
}

void test_std_setjmp_usage() {
  std::jmp_buf l1;       // NON_COMPLIANT
  if (setjmp(l1) == 0) { // NON_COMPLIANT
    std::longjmp(l1, 1); // NON_COMPLIANT
  }
}

void test_jmp_buf_declaration() {
  jmp_buf l1;      // NON_COMPLIANT
  std::jmp_buf l2; // NON_COMPLIANT
}

void test_compliant_alternative() {
  // Using structured exception handling or other alternatives
  // instead of setjmp/longjmp
  try {
    throw std::runtime_error("error");
  } catch (const std::runtime_error &) { // COMPLIANT
    // Handle error properly
  }
}

void test_jmp_buf_usage() { jmp_buf *l1; } // NON_COMPLIANT - pointer to jmp_buf