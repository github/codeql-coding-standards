#include <algorithm>
#include <vector>

class A {
  mutable int m;

public:
  A() : m(0) {}
  explicit A(int m) : m(m) {}

  A(const A &other) : m(other.m) { other.m = 0; } // NON_COMPLIANT

  A &operator=(const A &other) { // NON_COMPLIANT
    if (&other != this) {
      m = other.m;
      other.m = 0;
    }
    return *this;
  }

  int get_m() const { return m; }
};

class B {
  int m;

public:
  B() : m(0) {}
  explicit B(int m) : m(m) {}

  B(const B &other) : m(other.m) {}
  B(B &&other) : m(other.m) { other.m = 0; }

  B &operator=(const B &other) { // COMPLIANT
    if (&other != this) {
      m = other.m;
    }
    return *this;
  }

  B &operator=(B &&other) {
    m = other.m;
    other.m = 0;
    return *this;
  }

  int get_m() const { return m; }
};
