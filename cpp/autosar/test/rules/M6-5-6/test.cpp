void test_loop_control_variable_bool_type_in_statement() {
  bool testFlag = true;
  for (int x = 0; (x < 5) && testFlag; ++x) { // COMPLIANT
    testFlag = false;
  }
}

void updateFlag(bool *flag) { *flag = false; }

void test_loop_control_variable_bool_type_in_statement_fn() {
  bool testFlag = true;
  for (int x = 0; (x < 5) && testFlag; ++x) { // COMPLIANT
    updateFlag(&testFlag);
  }
}

int y = 10;
void test_loop_control_variable_bool_type_not_in_statement() {
  for (int x = 0; x < 5 && y == 9; ++x) { // NON_COMPLIANT
    x = x + 2;
    y--;
  }
}

int z = 3;
void updateLoopControlVariable(int *someLoopControlVariable) {
  *someLoopControlVariable--;
}

int updateLoopControlVariableTest() { return 1; }

void test_loop_control_variable_bool_type_not_in_statement_fn() {
  for (int x = 0; x < 5 && z == 1; ++x) { // NON_COMPLIANT
    x = x + 2;
    updateLoopControlVariable(&z);
    z = updateLoopControlVariableTest();
  }
}
