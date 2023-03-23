

void f1() {
  int l1;
  for (int i = 10; i; i++) { // NON_COMPLIANT
  }
  while (l1) { // NON_COMPLIANT
  }
}

void f2() {
  int j = 0;
  for (int i = 0; i < 10; i++) { // COMPLIANT
  }
}