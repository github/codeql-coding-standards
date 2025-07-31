#include <cstdint>
#include <memory>

struct A {
  std::int8_t i;
};

class B {};

void test_make_shared_compliant() {
  auto p = std::make_shared<A>(); // COMPLIANT
  std::int8_t *pi = &(p->i);
  std::shared_ptr<std::int8_t> q(
      p, pi); // COMPLIANT - aliasing constructor, not taking ownership
}

void test_make_unique_compliant() {
  auto p = std::make_unique<A>(); // COMPLIANT
}

void test_raw_pointer_shared_ptr_non_compliant() {
  A *l1 = new A();
  std::shared_ptr<A> l2(l1); // NON_COMPLIANT
}

void test_raw_pointer_unique_ptr_non_compliant() {
  A *l1 = new A();
  std::unique_ptr<A> l2(l1); // NON_COMPLIANT
}

auto test_exception_safety_issue() {
  auto *l1 = new A();
  auto l2 = std::make_unique<A>(); // may throw
  return std::shared_ptr<A>(l1);   // NON_COMPLIANT - memory leak
                                   // if make_unique throws
}

auto test_double_delete_issue(std::unique_ptr<A> p) {
  auto l1 = p.get();
  return std::unique_ptr<A>(l1); // NON_COMPLIANT - causes double delete
}

void f1(std::shared_ptr<A> a, std::shared_ptr<B> b);

void test_function_argument_non_compliant() {
  f1(std::shared_ptr<A>(new A()),  // NON_COMPLIANT
     std::shared_ptr<B>(new B())); // NON_COMPLIANT
}

void test_function_argument_compliant() {
  f1(std::make_shared<A>(),  // COMPLIANT
     std::make_shared<B>()); // COMPLIANT
}

void test_array_raw_pointer_non_compliant() {
  A *l1 = new A[10];
  std::unique_ptr<A[]> l2(l1); // NON_COMPLIANT
}

void test_array_make_unique_compliant() {
  auto l1 = std::make_unique<A[]>(10); // COMPLIANT
}

void test_custom_deleter_shared_ptr() {
  A *l1 = new A();
  auto l2 = [](A *p) { delete p; };
  std::shared_ptr<A> l3(l1, l2); // NON_COMPLIANT - still
                                 // using raw pointer constructor
}

void test_custom_deleter_unique_ptr() {
  A *l1 = new A();
  auto l2 = [](A *p) { delete p; };
  std::unique_ptr<A, decltype(l2)> l3(l1, l2); // NON_COMPLIANT - still
                                               // using raw pointer constructor
}

void test_nullptr_shared_ptr() {
  std::shared_ptr<A> l1(nullptr); // COMPLIANT - no ownership taken
}

void test_nullptr_unique_ptr() {
  std::unique_ptr<A> l1(nullptr); // COMPLIANT - no ownership taken
}