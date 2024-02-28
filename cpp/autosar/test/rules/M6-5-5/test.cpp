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

#include <vector>

void test_const_refs(std::vector<int> v) {
  std::vector<int>::iterator first = v.begin();
  std::vector<int>::iterator last = v.end();
  // call to operator!= passes a const reference to first
  for (; first != last; first++) { // COMPLIANT
  }
}

void update(std::vector<int>::iterator &f, const int &x, int &y) {}

void test_const_refs_update(std::vector<int> v) {
  std::vector<int>::iterator last = v.end();
  int x = 0;
  int y = 0;
  // call to operator!= passes a const reference to first
  for (std::vector<int>::iterator first = v.begin(); first != last; update(
           first, x, // COMPLIANT - first is a loop counter, so can be modified
           y)) {     // NON_COMPLIANT - y is modified and is not a loop counter
    first + 1;
  }
}