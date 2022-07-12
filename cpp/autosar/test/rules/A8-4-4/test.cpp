#include <tuple>

struct S {
  int s1;
  int s2;
};
std::tuple<int, int> test_return_tuple(int x, int y) { // COMPLIANT
  return std::make_tuple(x / y, x % y);
}
S test_return_struct(int x, int y) { // COMPLIANT
  S t;
  t.s1 = x / y;
  t.s2 = x % y;
  return t;
}

S test_return_struct1(int &x, int &y) { // COMPLIANT
  S t;
  t.s1 = x / y;
  t.s2 = x % y;
  return t;
}

int test_passbyreference_f1(int x, int y,
                            int &z) { // NON_COMPLIANT
  z = x % y;
  return x / y;
}

int test_passbyreference_f2(int x, int y, double &z) { // NON_COMPLIANT
  if (y == 0) {
    return (0);
  } else {
    z = (double)x / y;
    return (1);
  }
}
