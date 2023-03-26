void f1() {
  goto L1;
  for (int i = 0; i < 100; i++) {
  L1: // NON_COMPLIANT
    break;
  }
}

void f2() {
  int i = 0;
  if (i >= 0) {
    for (int j = 0; j < 10; j++) {
      goto L2;
    }
  }
L2: // COMPLIANT
  return;
}

void f3() {
  int i = 0;
  if (i >= 0) {
    for (int j = 0; j < 10; j++) {
      goto L3;
    L3: // COMPLIANT
      break;
    }
  }
}

void f4() {
  int i = 0;
L4: // COMPLIANT
  if (i >= 0) {
    goto L4;
  }
}

void f5(int p) {
  goto L1;

  switch (p) {
  case 0:
  L1:; // NON_COMPLIANT
    break;
  default:
    break;
  }
}

void f6(int p) {

  switch (p) {
  case 0:
    goto L1;
    break;
  default:
  L1: // NON_COMPLIANT
    break;
  }
}

void f7(int p) {
L1: // COMPLIANT
  switch (p) {
  case 0:
    goto L1;
    break;
  default:
    break;
  }
}

void f8(int p) {

  switch (p) {
  case 0:
    goto L1;
    ;
  L1:; // COMPLIANT
    break;
  default:
    break;
  }
}
