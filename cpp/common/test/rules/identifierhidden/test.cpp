int id1;

namespace {
int id1; // NON_COMPLIANT
}

namespace ns1 {
int id1; // COMPLIANT

namespace ns2 {
int id1; // COMPLIANT
}
} // namespace ns1

class C1 {
  int id1; // COMPLIANT
};

void f1() {
  int id1; // NON_COMPLIANT
}

void f2(int id1) {} // NON_COMPLIANT

void f3() {
  for (int id1; id1 < 1; id1++) { // NON_COMPLIANT
    for (int id1; id1 < 1; id1++) {
    } // NON_COMPLIANT
  }
}

template <typename T> constexpr bool foo = false; // COMPLIANT

namespace {
template <typename T> bool foo = true; // COMPLIANT - omit variable templates
}

template <class T> constexpr T foo1 = T(1.1L);

template <class T, class R> T f(T r) {
  T v = foo1<T> * r * r;  // COMPLIANT
  T v1 = foo1<R> * r * r; // COMPLIANT
}

void test_scope_order() {
  {
    {
      int i; // COMPLIANT
    }
    int i; // COMPLIANT
  }

  for (int i = 0; i < 10; i++) { // COMPLIANT
  }

  try {

  } catch (int i) { // COMPLIANT
  }

  int i; // COMPLIANT

  {
    {
      int i; // NON_COMPLIANT
    }
    int i; // NON_COMPLIANT
  }

  for (int i = 0; i < 10; i++) { // NON_COMPLIANT
  }

  try {

  } catch (int i) { // NON_COMPLIANT
  }
}