#include <cstdarg>
#include <cstdint>

void test_va_list_declaration() {
  va_list l1; // NON_COMPLIANT
}

void test_va_start_usage(std::int32_t l1, ...) {
  va_list l2;       // NON_COMPLIANT
  va_start(l2, l1); // NON_COMPLIANT
  va_end(l2);       // NON_COMPLIANT
}

void test_va_arg_usage(std::int32_t l1, ...) {
  va_list l2;                                 // NON_COMPLIANT
  va_start(l2, l1);                           // NON_COMPLIANT
  std::int32_t l3 = va_arg(l2, std::int32_t); // NON_COMPLIANT
  va_end(l2);                                 // NON_COMPLIANT
}

void test_va_end_usage(std::int32_t l1, ...) {
  va_list l2;       // NON_COMPLIANT
  va_start(l2, l1); // NON_COMPLIANT
  va_end(l2);       // NON_COMPLIANT
}

void test_va_copy_usage(std::int32_t l1, ...) {
  va_list l2, l3;   // NON_COMPLIANT
  va_start(l2, l1); // NON_COMPLIANT
  va_copy(l3, l2);  // NON_COMPLIANT
  va_end(l3);       // NON_COMPLIANT
  va_end(l2);       // NON_COMPLIANT
}

void test_va_list_parameter(va_list l1) { // NON_COMPLIANT
  double l2 = va_arg(l1, double);         // NON_COMPLIANT
}

void test_multiple_va_arg_calls(std::int32_t l1, ...) {
  va_list l2;                                 // NON_COMPLIANT
  va_start(l2, l1);                           // NON_COMPLIANT
  std::int32_t l3 = va_arg(l2, std::int32_t); // NON_COMPLIANT
  double l4 = va_arg(l2, double);             // NON_COMPLIANT
  va_end(l2);                                 // NON_COMPLIANT
}

void test_variadic_function_declaration(std::int16_t l1, ...) {
  // Function declaration with ellipsis is compliant
}

void test_variadic_function_call() {
  test_variadic_function_declaration(1, 2.0, 3.0); // COMPLIANT
}

typedef va_list va_list_alias; // NON_COMPLIANT
typedef va_list SOME_TYPE;     // NON_COMPLIANT
void test_va_list_alias() {
  va_list_alias l1; // NON_COMPLIANT
  SOME_TYPE l2;     // NON_COMPLIANT
}

// Note: use of va_list as a return type, or a cast, is not legal

void test_va_list() {
  va_list *l1; // NON_COMPLIANT - pointer to va_list
}