#include <cstdlib>

void test_direct_call_to_system() {
  std::system("echo hello"); // NON_COMPLIANT
}

void test_system_function_pointer() {
  auto l1 = &std::system;                // NON_COMPLIANT
  int (*l2)(const char *) = std::system; // NON_COMPLIANT
}

void test_system_address_taken() {
  void *l1 = reinterpret_cast<void *>(&std::system); // NON_COMPLIANT
}

void test_system_call_with_null() {
  std::system(nullptr); // NON_COMPLIANT
}

void test_system_call_with_variable() {
  const char *l1 = "ls";
  std::system(l1); // NON_COMPLIANT
}

void test_compliant_alternative() {
  // Using compliant alternatives instead of system()
  const char *l1 = "some command"; // COMPLIANT
  // Implementation-specific alternatives would be used here
}

// Test with C-style header (rule also applies to <stdlib.h>)
#include <stdlib.h>

void test_c_style_header_system() {
  system("echo hello"); // NON_COMPLIANT
}

void test_c_style_header_function_pointer() {
  int (*l1)(const char *) = system; // NON_COMPLIANT
}

#define system(x) 0
void test_system_macro_expansion() {
  system("echo test"); // NON_COMPLIANT
}
