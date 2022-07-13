void test_loop_control_variable_not_modified_in_condition_or_expression() {
  bool testFlag = true;
  for (int x = 0; (x < 5) && testFlag; ++x) { // COMPLIANT
    testFlag = false;
  }
}

bool updateFlag(bool *flag) {
  *flag = false;
  return *flag;
}

void test_loop_control_variable_modified_in_condition() {
  bool testFlag = true;
  bool testFlag2 = true;
  for (int x = 0; (x < 5) && updateFlag(&testFlag); ++x) { // NON_COMPLIANT
  }
}

bool updateFlagWithIncrement(int i) { return false; }
void test_loop_control_variable_modified_in_expression() {
  bool testFlag = true;
  for (int x = 0; (x < 5);
       testFlag = updateFlagWithIncrement(++x)) { // NON_COMPLIANT
  }
}
