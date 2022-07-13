// $Id: A7-5-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
class A {
public:
  explicit A(std::uint8_t n) : number(n) {}
  ~A() { number = 0U; }
  // Implementation

private:
  std::uint8_t number;
};
const A &Fn1(const A &ref) noexcept // Non-compliant - the function returns a
// reference to const reference parameter
// which may bind to temporary objects.
// According to C++14 Language Standard, it
// is undefined whether a temporary object is introduced for const
// reference
// parameter
{
  // ...
  return ref;
}
const A &Fn2(A &ref) noexcept // Compliant - non-const reference parameter does
// not bind to temporary objects, it is allowed
// that the function returns a reference to such
// a parameter
{
  // ...
  return ref;
}
const A *Fn3(const A &ref) noexcept // Non-compliant - the function returns a
// pointer to const reference parameter
// which may bind to temporary objects.
// According to C++14 Language Standard, it
// is undefined whether a temporary object is introduced for const
// reference
// parameter
{
  // ...
  return &ref;
}
template <typename T>
T &Fn4(T &v) // Compliant - the function will not bind to temporary objects
{
  // ...
  return v;
}
void F() noexcept {
  A a{5};
  const A &ref1 = Fn1(a); // fn1 called with an lvalue parameter from an
  // outer scope, ref1 refers to valid object
  const A &ref2 = Fn2(a); // fn2 called with an lvalue parameter from an
  // outer scope, ref2 refers to valid object
  const A *ptr1 = Fn3(a); // fn3 called with an lvalue parameter from an
  // outer scope, ptr1 refers to valid object
  const A &ref3 = Fn4(a); // fn4 called with T = A, an lvalue parameter from
  // an outer scope, ref3 refers to valid object

  const A &ref4 = Fn1(A{10}); // fn1 called with an rvalue parameter
  // (temporary), ref3 refers to destroyed object
  // A const& ref5 = fn2(A{10}); // Compilation
  // error - invalid initialization of non-const
  // reference
  const A *ptr2 = Fn3(A{15}); // fn3 called with an rvalue parameter
  // (temporary), ptr2 refers to destroyted
  // object
  // const A& ref6 = fn4(A{20}); // Compilation error - invalid
  // initialization of non-const reference
}