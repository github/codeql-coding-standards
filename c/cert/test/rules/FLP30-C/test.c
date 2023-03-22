void f1() {
  float f = 0.0F;
  for (f = 0.0F; f < 10.0F; f += 0.2F) { // NON_COMPLIANT
  }
  while (f < 10.0F) { // NON_COMPLIANT
    f = f * 2.0F;
  }

  do { // NON_COMPLIANT
    f *= 2.0F;
  } while (f < 10.0F);
}

void f2() {

  for (int i = 0; i < 10; i++) { // COMPLIANT
  }
  int j = 0;
  while (j < 10) { // COMPLIANT
    j = j * 2;
  }

  do {
    j++;
  } while (j < 10); // COMPLIANT
}
