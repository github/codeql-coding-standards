void dosomething();

bool updateFlag(bool *flag) {
  *flag = false;
  return *flag;
}
int someNumberUpdateForFunctionInUpdate = 4;
int updateLoopVariable() { return someNumberUpdateForFunctionInUpdate++; }

// A6-5-2 (M6-5-1) tests
void test_floating_point_loop() {
  for (float f = 0.0F; f < 10.0F; f += 0.2F) {
    dosomething();
    continue; // NON_COMPLIANT
  }
}

void test_non_floating_point_loop() {
  for (int i = 0; i < 10; i++) {
    dosomething();
    continue; // COMPLIANT
  }
}

void test_loop_with_multiple_loop_counters_declared() {
  for (int i = 0, j = 0; i < j; i++, j++) {
    dosomething();
    continue; // NON_COMPLIANT
  }
}

void test_loop_init_with_multiple_loop_counters_initialized() {
  int i, j;
  for (i = 0, j = 0; i < j; i++, j++) {
    dosomething();
    continue; // NON_COMPLIANT
  }
}

// M-6-5-2 tests
void test_loop_skips_condition() {
  for (int i = 0; i != 10; i += 3) {
    dosomething();
    continue; // NON_COMPLIANT
  }
}
void test_loop_does_not_skip_condition() {
  for (int i = 0; i != 10; i++) {
    dosomething();
    continue; // COMPLIANT
  }
}

// M6-5-3 tests
void updateLoopCounterInStatement(int *someLoopCounter) { *someLoopCounter++; }

void test_loop_counter_mod_in_statement_fn() {
  for (int x = 0; x < 100; x++) {
    updateLoopCounterInStatement(&x);
    continue; // NON-COMPLIANT
  }
}

void test_loop_counter_no_mod_in_condition_or_statement() {
  for (int x = 0; x < 10; x++) {
    dosomething();
    continue; // COMPLIANT
  }
}

// M6-5-4
int someOtherNumber = 10;
void test_loop_counter_increment_constant_n() {
  for (int i = 0; i < 100; i += someOtherNumber) {
    dosomething();
    continue; // COMPLIANT
  }
}

void test_loop_control_irregular_update_in_update() {
  for (int x = 0; x < 5; x += updateLoopVariable()) {
    dosomething();
    continue; // NON-COMPLIANT
  }
}

// M6-5-5
void test_loop_control_variable_not_modified_in_condition_or_expression() {
  bool testFlag = true;
  for (int x = 0; (x < 5) && testFlag; ++x) {
    testFlag = false;
    dosomething();
    continue; // COMPLIANT
  }
}

bool updateFlagWithIncrement(int i) { return false; }
void test_loop_control_variable_modified_in_expression() {
  bool testFlag = true;
  for (int x = 0; (x < 5); testFlag = updateFlagWithIncrement(++x)) {
    dosomething();
    continue; // NON-COMPLIANT
  }
}

// M6-5-6 tests
void test_loop_control_variable_bool_type_in_statement_fn() {
  bool testFlag = true;
  for (int x = 0; (x < 5) && testFlag; ++x) {
    dosomething();
    continue; // COMPLIANT
    updateFlag(&testFlag);
  }
}

int y = 10;
void test_loop_control_variable_bool_type_not_in_statement() {
  for (int x = 0; x < 5 && y == 9; ++x) {
    x = x + 2;
    y--;
    dosomething();
    continue; // NON-COMPLIANT
  }
}
