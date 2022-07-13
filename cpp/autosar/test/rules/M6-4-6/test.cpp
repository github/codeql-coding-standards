void test_switch_missing_default(int expression) {
  int i = 5;
  int j = 3;
  int k;
  switch (expression) // BAD
  {
  case 1:
    if (i < j) {
      k = i;
    }
    break;
  case 2:
    k = i;
    break;
  }
}

void test_switch_hasDefault(int expression) {
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

void test_switch_defaultNotFinalClause_invalid(int expression) {
  int i = 5;
  int j = 3;
  int k;
  switch (expression) // BAD
  {
  case 1:
    if (i < j) {
      k = i;
    }
    break;
  default:
    break;
  case 2:
    k = i;
    break;
  }
}