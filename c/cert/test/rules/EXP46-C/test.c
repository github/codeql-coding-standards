extern int f_get_int();

void test() {
  (void)(!(1 & 2 == 0));   // NON_COMPLIANT
  (void)(!(1 && 2 == 0));  // COMPLIANT
  (void)(!((1 & 2) == 0)); // COMPLIANT

  if (1 & 2) { // COMPLIANT
  }
  if (1 | 2) { // COMPLIANT
  }
  if (1 && 2) { // COMPLIANT
  }
  if (!(f_get_int() & f_get_int() == 0)) { // NON_COMPLIANT
  }
  if (!(f_get_int() & (f_get_int() == 0))) { // COMPLIANT
  }
  if (!(f_get_int() && f_get_int() == 0)) { // COMPLIANT
  }
}