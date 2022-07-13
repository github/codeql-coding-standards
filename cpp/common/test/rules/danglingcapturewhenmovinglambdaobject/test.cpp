#include <functional>

std::function<void()> g1, g2;

struct S1 {
  std::function<void()> m1, m2;
  std::function<int()> m3;
  int m4;

  void test_store_dangling_reference_to_local() {
    int l1;
    m1 = [&]() { l1++; };                // NON_COMPATIBLE
    m2 = [&l1]() { l1++; };              // NON_COMPATIBLE
    m3 = [=]() mutable { return ++l1; }; // COMPATIBLE
    g1 = [&]() { l1++; };                // NON_COMPATIBLE
    g2 = [=]() mutable { l1++; };        // COMPATIBLE
  }
};