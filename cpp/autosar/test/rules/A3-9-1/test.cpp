#include <cstdint>

void test_variable_width_type_variables() {
  char c;           // NON_COMPLIANT
  unsigned char uc; // COMPLIANT - covered by VariableWidthIntegerTypesUsed
  signed char sc;   // COMPLIANT - covered by VariableWidthIntegerTypesUsed
}

void test_variable_width_type_qualified_variables() {
  const char c1 = 0;           // NON_COMPLIANT
  const unsigned char uc1 = 0; // COMPLIANT - (VariableWidthIntegerTypesUsed)
  const signed char sc1 = 0;   // COMPLIANT - (VariableWidthIntegerTypesUsed)

  volatile char c2;           // NON_COMPLIANT
  volatile unsigned char uc2; // COMPLIANT - (VariableWidthIntegerTypesUsed)
  volatile signed char sc2;   // COMPLIANT - (VariableWidthIntegerTypesUsed)
}