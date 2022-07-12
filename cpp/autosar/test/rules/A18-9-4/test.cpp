#include <cstdint>
#include <utility>

template <typename T1, typename T2> void f1(T1 const &t1, T2 &t2);

template <typename T1, typename T2> void f2(T1 &&t1, T2 &&t2) {
  f1(std::forward<T1>(t1), std::forward<T2>(t2));
  ++t2; // NON_COMPLIANT
}

int main() {
  int i = 0;
  f2(0, i);
}
