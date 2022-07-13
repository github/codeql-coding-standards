int test_bool_literal_in_condition() {
  return true ? 1 : 0; // COMPLIANT
}

int test_bool_var_in_condition() {
  bool b = true;
  return b ? 1 : 0; // COMPLIANT
}

int test_bool_expr_in_condition() {
  return 4 < 5 ? 1 : 0; // COMPLIANT
}

int test_ptr_in_condition() {
  return nullptr ? 1 : 0; // NON_COMPLIANT
}

int test_int_in_condition() {
  return 0 ? 1 : 0; // NON_COMPLIANT
}

int test_char_in_condition() {
  return '0' ? 1 : 0; // NON_COMPLIANT
}

int test_ternary_operator_in_macro() {
#define MACRO(x) ((x) ? 1 : 0)
  return MACRO(0); // COMPLIANT
}