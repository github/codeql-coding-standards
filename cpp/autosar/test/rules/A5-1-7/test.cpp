#include <functional>
#include <typeinfo>

void f1() {
  auto l1 = []() { return 1; };
  auto l2 = []() { return 1; };

  const std::type_info &ti1 = typeid(l1); // NON_COMPLIANT
  const std::type_info &ti2 = typeid(l2); // NON_COMPLIANT

  if (ti1.hash_code() == ti2.hash_code()) { // always false
  }

  using t1 = decltype(l1); // NON_COMPLIANT
  // t1 l3 = []() { return 1; }; // no suitable user-defined conversion

  std::function<int()> l4 = []() { return 1; };
  std::function<int()> l5 = []() { return 1; };

  const std::type_info &ti3 = typeid(l4); // COMPLIANT
  const std::type_info &ti4 = typeid(l5); // COMPLIANT

  if (ti3.hash_code() == ti4.hash_code()) {
  }
}