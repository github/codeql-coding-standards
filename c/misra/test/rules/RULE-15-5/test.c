void f1(int p1) { // NON_COMPLIANT
  if (p1) {
    return;
  }
  return;
}

void f2(int p1) { // COMPLIANT
  if (p1) {
  }
  return;
}

void f3(int p1) { // NON_COMPLIANT
  if (p1) {
  }
  return;
  p1++;
}

void f4(int p1) { // NON_COMPLIANT
  if (p1) {
    return;
  }
  return;
  p1++;
}

void f5(); // Ignored - no body