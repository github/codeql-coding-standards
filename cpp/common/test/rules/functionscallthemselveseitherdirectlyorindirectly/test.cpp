
int f();
int test_indirect_recursive_f2(int i);

int test_recursive_function(int i) {
  if (i > 10) {
    i = i + test_recursive_function(i); // NON_COMPLIANT
  }
}

int test_nonrecursive_function(int i) { // COMPLIANT
  if (i < 10) {
    i = f();
    return i * i;
  }
  return i;
}

int test_indirect_recursive_function(int i) {
  if (i > 10) {
    i = test_recursive_function(i * i); // NON_COMPLIANT
  }
}

int test_indirect_recursive_f1(int i) {
  if (i > 10) {
    test_indirect_recursive_f2(i + i); // NON_COMPLIANT
  }
}

constexpr int test_consexpr_function(int n) {
  return n <= 1 ? 1
                : (n * test_consexpr_function(n - 1)); // COMPLIANT by exception
}

int test_indirect_recursive_f2(int i) {
  if (i > 10) {
    i = test_indirect_recursive_f1(i + 1); // NON_COMPLIANT
  }
}

// Veriadic templates
template <typename T> T f2(T value) { return value; }
template <typename T, typename... Args> T f2(T x, Args... args) {
  return x + f2(args...); // Compliant by exception -all of the
                          // arguments are known during compile time
}
int test_veriafic_functions() noexcept {
  int i = f2<int, int, float, double>(
      10, 5, 2.5, 3.5); // An example call to variadic template function
  return i;
}

class C2 {

public:
  int a;
};

class C1 {

public:
  C2 a;
};

class C3 {};

bool operator==(const C2 &a, const C2 &b) { return a.a == b.a; }

bool operator==(const C1 &a, const C1 &b) {
  return operator==(a.a, b.a); // COMPLIANT
}

bool operator==(const C3 &a, const C3 &b) {
  return operator==(a, b); // NON_COMPLIANT
}
