int g1 = 0;

void f1() {
  decltype(g1++) l1; // NON_COMPLIANT

  decltype(g1) l2; // COMPLIANT
}

void abort();
#define m(x, y)                                                                \
  do {                                                                         \
    decltype(x) l1 = x + y;                                                    \
    if (l1 < x && l1 < y) {                                                    \
      abort();                                                                 \
    }                                                                          \
  } while (0)

void f2() {
  m(g1++, 1); // COMPLIANT, permissible since used in macro defintion
}

template <class T> struct hasX {
  template <typename C>
  static constexpr decltype(C().x(), bool()) // COMPLIANT, in SFINAE context
  test(int) {
    return true;
  }

  template <typename C> static constexpr bool test(...) { return false; }

  static constexpr bool value = test<T>(int());
};