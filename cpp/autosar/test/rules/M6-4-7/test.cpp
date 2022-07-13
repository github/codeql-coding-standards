void test_switch_valid_condition(int expression) {
  int i = 5;
  int j = 3;
  int k;
  switch (expression) // GOOD
  {
  case 1:
    if (i < j) {
      k = i;
    }
    break;
  case 2:
    k = i;
    break;
  default:
    break;
  }
}

void test_switch_invalid_condition(int expression) {
  switch (expression == 1) // BAD
  {
  case 0:
    break;
  case 1:
    break;
  default:
    break;
  }
}

void test_switch_invalid_condition2(char *expression) {
  switch (expression == "BAD") // BAD
  {
  case 0:
    break;
  case 1:
    break;
  default:
    break;
  }
}