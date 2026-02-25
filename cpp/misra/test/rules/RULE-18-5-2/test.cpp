#include "custom_abort.h"
#include <cassert>
#include <cstdlib>
#include <stdexcept>

void test_direct_calls_to_terminating_functions() {
  // Direct calls to program-terminating functions
  abort();       // NON_COMPLIANT
  exit(0);       // NON_COMPLIANT
  _Exit(1);      // NON_COMPLIANT
  quick_exit(2); // NON_COMPLIANT
}

void test_std_namespace_calls() {
  // Calls to functions in std namespace
  std::abort();       // NON_COMPLIANT
  std::exit(0);       // NON_COMPLIANT
  std::_Exit(1);      // NON_COMPLIANT
  std::quick_exit(2); // NON_COMPLIANT
  std::terminate();   // NON_COMPLIANT
}

void test_taking_addresses_of_terminating_functions() {
  // Taking addresses of program-terminating functions
  auto l1 = &abort;           // NON_COMPLIANT
  auto l2 = &exit;            // NON_COMPLIANT
  auto l3 = &_Exit;           // NON_COMPLIANT
  auto l4 = &quick_exit;      // NON_COMPLIANT
  auto l5 = &std::abort;      // NON_COMPLIANT
  auto l6 = &std::exit;       // NON_COMPLIANT
  auto l7 = &std::_Exit;      // NON_COMPLIANT
  auto l8 = &std::quick_exit; // NON_COMPLIANT
  auto l9 = &std::terminate;  // NON_COMPLIANT
}

void test_function_pointers_to_terminating_functions() {
  // Function pointers to program-terminating functions
  void (*l1)() = abort;              // NON_COMPLIANT
  void (*l2)(int) = exit;            // NON_COMPLIANT
  void (*l3)(int) = _Exit;           // NON_COMPLIANT
  void (*l4)(int) = quick_exit;      // NON_COMPLIANT
  void (*l5)() = std::abort;         // NON_COMPLIANT
  void (*l6)(int) = std::exit;       // NON_COMPLIANT
  void (*l7)(int) = std::_Exit;      // NON_COMPLIANT
  void (*l8)(int) = std::quick_exit; // NON_COMPLIANT
  void (*l9)() = std::terminate;     // NON_COMPLIANT
}

void test_assert_macro_exception() {
  // The call to abort via assert macro is compliant by exception
  assert(true);   // COMPLIANT
  assert(1 == 1); // COMPLIANT
}

void f1() {
  // Valid alternative: normal function return
  return; // COMPLIANT
}

void test_compliant_alternatives() {
  // Using normal control flow instead of terminating functions
  f1(); // COMPLIANT

  // Using exceptions for error handling
  throw std::runtime_error("error"); // COMPLIANT
}

#define CALL_ABORT() std::abort()         // NON_COMPLIANT
#define CALL_EXIT(x) std::exit(x)         // NON_COMPLIANT
#define CALL_TERMINATE() std::terminate() // NON_COMPLIANT

void test_macro_expansion_with_terminating_functions() {
  // Macro expansions containing terminating functions
  CALL_ABORT();     // reported at the definition site
  CALL_EXIT(1);     // reported at the definition site
  CALL_TERMINATE(); // reported at the definition site
  LIBRARY_ABORT();  // NON_COMPLIANT - macro not defined by user, so flagged at
                    // the call site
}