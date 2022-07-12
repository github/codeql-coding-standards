int g1 = 0;

void f1() {
  int l1 = 0;
  [&]() {
    l1++; // NON_COMPLIANT
  };

  int l2 = 0;
  [&l2]() {
    l2++; // COMPLIANT
  };

  static int l3 = 0;
  []() {
    l3++; // COMPLIANT - exception, implicit capture of `l3` with non-automatic
          // storage duration
  };

  []() {
    g1++; // COMPLIANT
  };
}

namespace ns1 {
int m1;

void f1() {
  []() {
    m1++; // COMPLIANT
  };
}
} // namespace ns1

void f2() {
  thread_local int tl1 = 0;
  []() {
    tl1++; // COMPLIANT
  };
}