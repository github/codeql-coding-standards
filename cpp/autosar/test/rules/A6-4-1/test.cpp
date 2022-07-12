void test_switch_less_than_two_cases(int i, int expression) {
  // BAD
  switch (expression) {
  case 0:
    while (i < 10) {
      i = i + expression;
    }
    break;
  default:
    break;
  }
}

void test_switch_valid_case_number(int i, int expression) {
  // GOOD
  switch (expression) {
  case 0:
    while (i < 10) {
      i = i + expression;
    }
    break;
  case 1:
    if (i > 10) {
      i = i * i;
    }
    break;
  default:
    break;
  }
}