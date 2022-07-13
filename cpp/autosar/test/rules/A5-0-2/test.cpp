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

void test_non_boolean_iterations() {
  int j;
  for (int i = 10; i; i++) { // NON_COMPLIANT
    j = 3;
  }

  while (j) { // NON_COMPLIANT
    int k = 3;
  }
}

void test_boolean_iterations() {
  int j = 0;
  for (int i = 0; i < 10; i++) { // COMPLIANT
    j = i + j;
  }

  int boolean = 0;
  while (bool(boolean)) { // COMPLIANT
    j = 5;
  }

  while (int i = 0) { // COMPLIANT - due to exception
  }

  ClassA a;
  while (a) { // COMPLIANT - a has an explicit operator bool()
  }
}

template <class T> class ClassB {
public:
  std::deque<T> d;
  void f() {
    if (d.empty()) { // COMPLIANT
    }
  }
};

void class_b_test() {
  ClassB<int> b;

  b.f();
}

class ClassC {
  void run() {
    std::deque<int> d;
    if (!d.empty()) { // COMPLIANT
    }
  }
};