int *test_ptr_return_f2() {
  int x = 100;
  return &x; // NON_COMPLIANT
}

int *test_ptr_return_f3(int y) { return &y; } // NON_COMPLIANT

int &test_ref_return_f2() {
  int x = 100;
  return x; // NON_COMPLIANT
}

int &test_ref_return_f3(int y) { return y; } // NON_COMPLIANT

int *test_ptr_return_f4() {
  static int x = 1;
  return &x; // COMPLIANT
}

int test_return_f2() {
  int x = 100;
  return x; // COMPLIANT
}
template <typename T> void t1(T &x, T &y) {
  if (x > y)
    x = y; // NON_COMPLIANT[FALSE NEGATIVE]
  else
    x = -y; // NON_COMPLIANT[FALSE NEGATIVE]
}

void test_templatefunction_return() {
  int j = 2;
  int k = 3;
  t1(j, k);
}