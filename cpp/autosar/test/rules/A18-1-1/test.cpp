
int y[100]; // NON_COMPLIANT

class C {
public:
  static constexpr int a[]{0, 1, 2}; // COMPLIANT
};

int test_c_arrays() {

  int x[100];                 // NON_COMPLIANT
  constexpr int a[]{0, 1, 2}; // NON_COMPLIANT

  __func__; // COMPLAINT
  return 0;
}