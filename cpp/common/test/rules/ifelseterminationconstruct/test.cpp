
void test_ifelse_valid(int expression) {
  int i = 3;
  int j = 4;
  int k;
  if (expression > 0) { // GOOD
    k = i + j;
  } else if (expression < 100) {
    k = i - j;
  } else {
    k = j * j;
  }
}
void test_ifelse_mix_validity(int expression) {
  int i = 4;
  int j = 7;
  int k;
  if (expression > 0) { // GOOD
    k = i * i;
  }
  if (expression > 10) { // BAD
    k = i + j;
  } else if (expression < 0) {
    k = i * 2;
  }
}

void test_ifelse_nested_invalid(int expression) {
  int i = 5;
  int j = 7;
  int k;

  if (expression > 0) { // GOOD
    k = i * i * i;
  } else {
    k = i * j;
  }
  if (expression > 10) { // GOOD
    k = i;
  } else if (expression < 0) {
    if (expression < -10) { // BAD
      k = 5 + j;
    } else if (expression < -20) {
      k = i * 3;
    }
  } else {
    k = 3;
  }
}

void test_ifelse_nested_valid(int expression) {
  int i = 3;
  int j = 1;
  int k;
  if (expression > 10) { // BAD
    k = i + j;
  } else if (expression < 0) {
    if (i > 3) { // GOOD
      k = j;
    } else if (i < 10) {
      k = i % 3;
    } else {
      i = i % 2;
    }
  }
}
