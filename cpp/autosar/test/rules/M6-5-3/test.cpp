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

void test_loop_counter_reference_mod_in_condition() {
  auto loop = [](int &i) {
    for (; (i++ < 10); i++) { // NON_COMPLIANT
    }
  };
  int i = 0;
  loop(i);
}

void test_loop_counter_reference_mod() {
  auto loop = [](int &i) {
    for (; i < 10; i++) { // COMPLIANT
    }
  };
  int i = 0;
  loop(i);
}

void test_loop_const_reference() {
  auto loop = []([[maybe_unused]] int const &i) {
    for (int i = 0; i < 10; i++) { // COMPLIANT
    }
  };
  int i = 0;
  loop(i);
}

void test_loop_counter_reference_mod_in_statement() {
  auto loop = [](int &i) {
    for (; (i < 10); i++) {
      i++; // NON_COMPLIANT
    }
  };
  int i = 0;
  loop(i);
}

int const_reference(int const &i) { return i; }

int reference(int &i) { return i; }

int copy(int i) { return i; }

void test_pass_argument_by() {
  for (int i = 0; i < 10; i++) {
    const_reference(i); // COMPLIANT
    reference(i);       // NON_COMPLIANT
    copy(i);            // COMPLIANT
  }
}
