int g1 = 0;

int f1() { return g1++; }
int f2() { return 1; }

void f3() {
  if (noexcept(f1())) { // NON_COMPLIANT
  }

  if (noexcept(f2())) { // COMPLIANT, but due to side effect over-approximation
                        // still reported
  }
}

#define m1(x)                                                                  \
  do {                                                                         \
    if (noexcept(x)) {                                                         \
      g1 = (x) + 1;                                                            \
    } else {                                                                   \
      g1 = (x)-1;                                                              \
    }                                                                          \
  } while (0)

void f4() {
  m1(g1++); // COMPLIANT
}
