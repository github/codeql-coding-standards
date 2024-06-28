void test_loop_missing_braces(int expression) {
  for (int i = 0; i < expression; i++) // BAD
    expression = expression % 2;
}

void test_loop_valid_braces_check(int expression) {
  for (int i = 0; i < expression; i++) { // GOOD
    expression = expression % 2;
  }

  int j = 10;
  while (expression < 10) // BAD
    j = j + 10;
}

void test_loop_mix_validity(int expression) {
  do // BAD
    expression = expression % 2;
  while (expression < 10);

  while (expression > 10) // GOOD
  {
    expression = expression * 2;
  }

  do { // GOOD
    expression = expression % 2;
  } while (expression < 5);
}

void test_switch_valid_braces(int i, int expression) {
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

void test_switch_invalid_braces(int i, int expression) {
  // BAD
  switch (expression)
  case 0:
    while (i < 10) {
      i = i + expression;
    }
}
