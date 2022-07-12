void test_loop_counter_mod_in_condition() {
  for (int i = 0; (i++ < 10); i++) { // NON_COMPLIANT
  }
}

int updateLoopCounter(int *someLoopCounter) { return (*someLoopCounter)++; }

void test_loop_counter_mod_in_condition_fn() {
  for (int x = 0; updateLoopCounter(&x) < 20; ++x) { // NON_COMPLIANT
  }
}

void test_loop_counter_mod_in_statement() {
  for (int x = 0; x < 100; x++) { // NON_COMPLIANT
    x = x + 3;
  }
}

void updateLoopCounterInStatement(int *someLoopCounter) {
  (*someLoopCounter)++;
}

void test_loop_counter_mod_in_statement_fn() {
  for (int x = 0; x < 100; x++) { // NON_COMPLIANT
    updateLoopCounterInStatement(&x);
  }
}

void test_loop_counter_no_mod_in_condition_or_statement() {
  for (int x = 0; x < 10; x++) { // COMPLIANT
  }
}

void test_loop_counter_mod_in_statement2_fn() {
  for (int x = 0; x < 100; x++)
    x++; // NON_COMPLIANT
}

void inc(int &x) { x++; }

void test_loop_counter_mod_in_side_effect() {
  for (int i = 0; i < 10; i++) {
    inc(i); // NON_COMPLIANT - modifies `i`
  }
}
