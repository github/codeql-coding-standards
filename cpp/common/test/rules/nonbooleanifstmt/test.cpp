
#include <deque>

int f();
void *g();

void test_non_boolean_conditions() {
  int i = 1;
  if (i) { // NON_COMPLIANT
  }
  if (f()) { // NON_COMPLIANT
  }
  void *a = g();
  if (a) { // NON_COMPLIANT
  }
}

class ClassA {
public:
  explicit operator bool() const { return true; }
};

void test_boolean_conditions() {
  int i = 1;
  if ((bool)i) { // COMPLIANT
  }

  int n = 1;
  if ((const bool)n) { // COMPLIANT - handles accesses of const bool
  }

  const bool constj = true;
  const bool constk = false;
  if (n && (constj <= constk)) { // COMPLIANT -  handles accesses of const bool
  }

  bool j = true;
  bool k = false;
  if (i && (j <= k)) { // COMPLIANT - because of C++ standard
  }

  if (int i = 0) { // COMPLIANT - due to exception
  }

  ClassA a;
  if (a) { // COMPLIANT - a has an explicit operator bool()
  }
}

template <typename T> bool test_fp_reported_in_10a(T &p1) {
  if (p1.length() > 10) { // COMPLIANT
    return true;
  }
  return false;
}

#include <string>
void test_fp_reported_in_10b() {
  std::string s;
  test_fp_reported_in_10a(s);
}