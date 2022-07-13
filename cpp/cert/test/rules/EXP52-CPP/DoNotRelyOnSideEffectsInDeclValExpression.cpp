#include <utility>

int g1 = 0;

decltype(std::declval<int &>()) g2 = g1; // COMPLIANT
decltype(std::declval<int &>()++) g3;    // NON_COMPLIANT

struct C1 {
  C1() = delete;
  int m1() const { return 1; }
};

struct C2 {
  C2() = delete;
  int m1() { return g1++; }
};

decltype(std::declval<C1>().m1()) g4; // COMPLIANT
decltype(std::declval<C2>().m1()) g5; // NON_COMPLIANT

template <class T> struct hasX {
  template <typename C>
  static constexpr decltype(std::declval<C>().x()++,
                            bool()) // COMPLIANT, in SFINAE context
  test(int) {
    return true;
  }

  template <typename C> static constexpr bool test(...) { return false; }

  static constexpr bool value = test<T>(int());
};