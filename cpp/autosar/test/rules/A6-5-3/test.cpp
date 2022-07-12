void test_do_statement_is_used() {
  do {
  } while (1); // NON_COMPLIANT
}

void test_do_statement_is_not_used() {
  while (1) // COMPLIANT
    ;
}