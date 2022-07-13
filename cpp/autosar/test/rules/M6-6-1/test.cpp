void test_goto_invalid() {
  int j = 100;
  int i = 0;
  goto BAD;
  for (i = 0; i < 100; i++) {
  BAD: // BAD
    j = 1;
  }
}

void test_goto_valid() {
  int i = 0;
  int j = 0;

  if (i >= 0) {
    for (j = 0; j < 10; j++) {
      goto GOOD;
    }
  }
GOOD: // GOOD
  j = 5;
}

void test_goto_sameblock_valid() {
  int i = 0;
  int j = 0;

  if (i >= 0) {
    for (j = 0; j < 10; j++) {
      goto GOOD;
    GOOD: // GOOD
      j = 5;
    }
  }
}