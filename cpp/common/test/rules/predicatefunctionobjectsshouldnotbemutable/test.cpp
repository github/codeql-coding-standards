#include <algorithm>
#include <functional>

struct C1 {
  bool operator()(int p1) {
    if (p1 % 2 == 0) {
      m1++;
      return true;
    }
    return false;
  };

private:
  int m1;
};

typedef bool (*UnaryIntPredicate)(int);

struct C2 {
  static bool m1(int p1) { return p1 % 3 == 0; }
  operator UnaryIntPredicate() { return &m1; }
};

#define array_count(x) (sizeof(x) / sizeof(x[0]))

int g1 = 0;

bool pure_even(int i) { return i % 2 == 0; }

bool nonpure_even(int i) {
  g1++;
  return pure_even(i);
}

void f1() {
  int l1[] = {0, 1, 3, 4, 5, 6};
  C1 l2;
  C2 l3;

  UnaryIntPredicate l4 = &pure_even;
  UnaryIntPredicate l5 = &nonpure_even;

  int l6 = 0;

  std::remove_if(l1, l1 + array_count(l1), l2); // NON_COMPLIANT
  std::remove_if(l1, l1 + array_count(l1),
                 std::ref(l2)); // COMPLIANT - when function object is copied we
                                // alway reference the same function object

  std::remove_if(l1, l1 + array_count(l1), C1()); // NON_COMPLIANT

  std::remove_if(l1, l1 + array_count(l1), [](int i) {
    g1++;
    return i % 2 == 0;
  }); // NON_COMPLIANT - when function object is copied the identity may have
      // changed
  std::remove_if(l1, l1 + array_count(l1), [l6](int i) mutable {
    l6++;
    return i % 2 == 0;
  }); // NON_COMPLIANT - when function object is copied the identity is changed
  std::remove_if(l1, l1 + array_count(l1), [&l6](int i) {
    l6++;
    return i % 2 == 0;
  }); // NON_COMPLIANT - when function object is copied the identity may have
      // changed

  std::remove_if(l1, l1 + array_count(l1),
                 l5); // NON_COMPLIANT - when function object is copied the
                      // identity may have changed
  std::remove_if(l1, l1 + array_count(l1),
                 nonpure_even); // NON_COMPLIANT - when function object is
                                // copied the identity may have changed

  std::remove_if(l1, l1 + array_count(l1), C2());   // COMPLIANT
  std::remove_if(l1, l1 + array_count(l1), C2::m1); // COMPLIANT

  std::remove_if(l1, l1 + array_count(l1), pure_even); // COMPLIANT
  std::remove_if(l1, l1 + array_count(l1), l4);        // COMPLIANT

  std::remove_if(l1, l1 + array_count(l1),
                 [](int i) { return i % 2 == 0; }); // COMPLIANT
}