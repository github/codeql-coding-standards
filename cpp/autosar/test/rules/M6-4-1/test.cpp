void test_if_not_compound(int expression) {
  if (expression > 0) // BAD
    expression++;
}

void test_all_if_compounds(int expression) {
  int i = 6;
  int j = 8;

  if (expression > 0) { // GOOD
    i = 8;
    j = 9;
  }

  if (expression > 10) { // GOOD
    i = 3;
    if (i > 2) // BAD
      i++;
    j++;
  }
}
