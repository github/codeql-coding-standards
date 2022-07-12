// Rule A18-9-3 (required, implementation, automated)
// The std::move shall not be used on objects declared const or const&.
// If an object is declared const or const&, then it will actually never be
// moved using the std::move.

#include <utility>
class A {
  // Implementation
};
void F1() {
  const A a1{};
  A a2 = a1;
  const A &a3{a1};
  // copy constructor is called implicitly instead of move constructor
  A a4 = std::move(a1); // NON_COMPLIANT
  a4 = std::move(a2);   // COMPLIANT
  a4 = std::move(a3);   // NON_COMPLIANT
}
