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

void f4() {
  int a1, b;
  auto lambda1 = [a1]() {
    int b = 10; // COMPLIANT - exception - non captured variable b
  };

  auto lambda2 = [b]() {
    int b = 10; // NON_COMPLIANT - not an exception - captured
                // variable b
  };
}

int globalvar = 0;
int f5() {
  auto lambda_with_shadowing = []() {
    int globalvar = 1; // NON_COMPLIANT - not an exception - not captured but
                       // still accessible
    return globalvar + globalvar;
  };

  auto lambda_without_shadowing = []() { return globalvar + globalvar; };

  return lambda_with_shadowing();
}

void f6(int p) {
  // Introduce a nested scope to test scope comparison.
  if (p != 0) {
    int a1, b;
    auto lambda1 = [a1]() {
      int b = 10; // COMPLIANT - exception - non captured variable b
    };

    auto lambda2 = [b]() {
      int b = 10; // NON_COMPLIANT - not an exception - captured
                  // variable b
    };
  }
}

void f7() {
  static int a1;
  auto lambda1 = []() {
    int a1 = 10; // NON_COMPLIANT - Lambda can access static variable.
  };

  thread_local int a2;
  auto lambda2 = []() {
    int a2 = 10; // NON_COMPLIANT - Lambda can access thread local variable.
  };

  constexpr int a3 = 10;
  auto lambda3 = []() {
    int a3 = a3 + 1; // NON_COMPLIANT - Lambda can access const
                     // expression without mutable members.
  };

  const int &a4 = a3;
  auto lambda4 = []() {
    int a4 = a4 + 1; // NON_COMPLIANT[FALSE_NEGATIVE] - Lambda can access
                     // reference initialized with constant expression.
  };

  const int a5 = 10;
  auto lambda5 = []() {
    int a5 = a5 + 1; // NON_COMPLIANT - Lambda can access const
                     // non-volatile integral or enumeration type initialized
                     // with constant expression.
  };

  volatile const int a6 = 10;
  auto lambda6 = []() {
    int a6 =
        a6 + 1; // COMPLIANT - Lambda cannot access const volatile integral or
                // enumeration type initialized with constant expression.
  };
}