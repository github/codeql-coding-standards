void test_loop_counter_increment() {
  for (int i = 0; i < 10; i++) { // COMPLIANT
  }
}

void test_loop_counter_assign_add() {
  for (int i = 0; i < 10; i += 1) { // COMPLIANT
  }
}

void test_loop_counter_decrement() {
  for (int i = 10; i > 0; i--) { // COMPLIANT
  }
}

void test_loop_assign_subtract() {
  for (int i = 10; i > 0; i -= 1) { // COMPLIANT
  }
}

int someOtherNumber = 10;
void test_loop_counter_increment_constant_n() {
  for (int i = 0; i < 100; i += someOtherNumber) { // COMPLIANT
  }
}

int someNumberUpdateForFunctionInUpdate = 4;
int updateLoopVariable() { return someNumberUpdateForFunctionInUpdate++; }

void test_loop_control_irregular_update_in_update() {
  for (int x = 0; x < 5; x += updateLoopVariable()) { // NON_COMPLIANT
  }
}

int someNumberUpdateForStatement = 1;
void test_loop_control_irregular_update_in_statement() {
  for (int x = 0; x < 5; x += someNumberUpdateForStatement) { // NON_COMPLIANT
    someNumberUpdateForStatement += 2;
  }
}

int someNumberUpdateForCondition = 93;
void test_loop_control_irregular_update_in_condition() {
  for (int x = 0; x < 5 && someNumberUpdateForCondition++ < 100;
       x += someNumberUpdateForCondition) { // NON_COMPLIANT
  }
}
