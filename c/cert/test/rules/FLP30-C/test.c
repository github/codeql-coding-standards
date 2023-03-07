void f1() {
  float f = 0.0F;
  for (f = 0.0F; f < 10.0F; f += 0.2F) { // NON_COMPLIANT
  }
  while (f - 0.0F) { // NON_COMPLIANT
  }
}

void f2() {

  for (int i = 0; i < 10; i++) { // COMPLIANT
  }
  while (4 - 4) { // COMPLIANT
  }
}
