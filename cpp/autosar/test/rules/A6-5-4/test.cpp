void test_single_loop_counter() {
  for (int i = 0; i < 10; i++) { // COMPLIANT
  }

  int a;
  for (a = 0; a < 10; a++) { // COMPLIANT
  }

  for (int i = 0, j = 0; i < j;) { // NON_COMPLIANT
  }

  int x, y;
  for (x = 0, y = 0; x < y;) { // NON_COMPLIANT
  }
}

int inc(int &i) {
  i++;
  // and do other stuff...
}

void test_loop_update_only_updates_loop_counter() {
  for (int i = 0;; i++) { // COMPLIANT
  }

  for (int i = 0;; i += 2) { // COMPLIANT
  }

  for (int i = 0, j = 0;; i--, j++) { // COMPLIANT
  }

  for (int i = 0, j = 0;; i++) { // NON_COMPLIANT
  }

  for (int i = 0;; inc(i)) { // NON_COMPLIANT
  }
}