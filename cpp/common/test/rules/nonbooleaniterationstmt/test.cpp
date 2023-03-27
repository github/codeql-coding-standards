#include <deque>

int f();
void *g();
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