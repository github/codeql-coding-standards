void f();

void test_switch_nested_case_invalid(int expression) {
  int i = 5;
  int j;
  switch (expression) {
  case 1: // BAD
    if (i > 4) {
    case 2:
      j = 3;
      break;
    }
    break;
  default:
    j = 5;
    break;
  }
}

void test_switch_nested_case_invalid_2(int expression) {
  int i = 5;
  int j;
  switch (expression) {
  case 1:
    if (i > 4) {
      j = 3;
    }
    break;
  case 2:
    if (i % 2 == 0) {
      j = 1;
    }
  case 3:
    if (i % 2 == 1) {
      j = 8;
    case 4: // BAD
      j++;
    }
    break;
  default:
    j = 5;
    break;
  }
}

void test_switch_valid(int expression) {

  int i = 5;
  int j;
  switch (expression) {
  case 1:
    if (i > 4) {
      j = 3;
    }
    break;
  case 2:
    if (i % 2 == 0) {
      j = 1;
    }
    break;
  case 3:
    if (i % 2 == 1) {
      j = 8;
    }
    break;
  default:
    j = 5;
    break;
  }
}

void test_singlecase_invalid(int expression) {
  switch (expression) {
    {
    case 1:
      f();
    }
  }
}