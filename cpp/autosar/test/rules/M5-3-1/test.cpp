#include <vector>

void test_if_sequences() {

  int n, k, i, m;
  if ((n < m) && (i < k))
    ; // COMPLIANT
  if ((n < m) || (i < k))
    ; // COMPLIANT
  if (!0 && (i < k))
    ; // NON_COMPLIANT
  if (0 && (i + k))
    ; // NON_COMPLIANT
}

template <typename T = int> class A {
public:
  std::vector<T> _queue;

  bool test1() {
    return !_queue.empty(); // COMPLIANT
  }
};

void f() {
  A<int> a;
  a.test1();
}