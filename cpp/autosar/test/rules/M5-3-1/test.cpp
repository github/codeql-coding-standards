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

template <typename T> constexpr bool some_variable_template_v = false;
template <> constexpr bool some_variable_template_v<int> = true;

template <typename S>
void template_with_no_except() noexcept(some_variable_template_v<S> &&
                                        true) { // COMPLIANT
}
void test_template() { template_with_no_except<int>(); }