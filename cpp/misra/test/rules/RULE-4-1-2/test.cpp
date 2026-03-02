#include <exception>
#include <functional>
#include <memory>

// COMPLIANT - normal exception handling
void f1() {
  try {
  } catch (const std::exception &) {
  }
}

bool f2() { return std::uncaught_exception(); } // NON_COMPLIANT

struct IsZero {
  typedef int argument_type;
  bool operator()(int x) const { return x == 0; }
};

struct NotEqual {
  typedef int first_argument_type;
  typedef int second_argument_type;
  bool operator()(int x, int y) const { return x != y; }
};

std::unary_negate<IsZero> g1;    // NON_COMPLIANT
std::binary_negate<NotEqual> g2; // NON_COMPLIANT

void f3() {
  std::unary_negate<IsZero> l1;    // NON_COMPLIANT
  std::binary_negate<NotEqual> l2; // NON_COMPLIANT
  std::function<bool(int)> l3;     // COMPLIANT
}

void f4() {
  std::shared_ptr<int> p1;
  p1.unique();          // NON_COMPLIANT
  p1.use_count();       // COMPLIANT
  (void)p1.unique();    // NON_COMPLIANT
  bool b = p1.unique(); // NON_COMPLIANT
}

void f5(std::shared_ptr<int> p1) {
  p1.unique(); // NON_COMPLIANT
}

#include <ccomplex>   // NON_COMPLIANT
#include <complex>    // COMPLIANT
#include <cstdalign>  // NON_COMPLIANT
#include <cstdbool>   // NON_COMPLIANT
#include <ctgmath>    // NON_COMPLIANT
#include <stdalign.h> // COMPLIANT
#include <stdbool.h>  // COMPLIANT
#include <tgmath.h>   // COMPLIANT
#include <type_traits>

void f6() {
  std::is_literal_type<int> l1;                 // NON_COMPLIANT
  bool b = std::is_literal_type<int>::value;    // NON_COMPLIANT
  std::is_trivially_copy_constructible<int> l2; // COMPLIANT
}

struct my_type;
template <>
struct std::is_literal_type<my_type> {}; // NON_COMPLIANT - specialization

void f7() {
  bool b = std::is_literal_type_v<int>;       // NON_COMPLIANT
  bool c = std::is_trivially_copyable_v<int>; // COMPLIANT
}

void f8() {
  auto buf = std::get_temporary_buffer<int>(10); // NON_COMPLIANT
  std::return_temporary_buffer(buf.first);       // NON_COMPLIANT
  int *p = new int[10];                          // COMPLIANT
  delete[] p;
}

void f9(std::raw_storage_iterator<int *, int> r) { // NON_COMPLIANT
  std::raw_storage_iterator<int *, int> r2 = r;    // NON_COMPLIANT
  int *p = new int[10];                            // COMPLIANT
  delete[] p;
}

void f10() {
  std::allocator<int> a;          // COMPLIANT
  std::allocator<int>::pointer p; // NON_COMPLIANT
  p = a.allocate(10);             // COMPLIANT
  p = a.allocate(10, nullptr);    // NON_COMPLIANT
  a.address(*p);                  // NON_COMPLIANT
  a.construct(p, 42);             // NON_COMPLIANT
  a.destroy(p);                   // NON_COMPLIANT
  a.deallocate(p, 10);            // COMPLIANT
  a.max_size();                   // NON_COMPLIANT
}

typedef std::allocator<int>::rebind<char>::other CharAlloc; // NON_COMPLIANT

void f11() {
  std::allocator<void> av; // NON_COMPLIANT
}

void f12() {
  std::plus<int>::result_type r1;          // NON_COMPLIANT
  std::plus<int>::first_argument_type r2;  // NON_COMPLIANT
  std::plus<int>::second_argument_type r3; // NON_COMPLIANT
  std::negate<int>::result_type r4;        // NON_COMPLIANT
  std::negate<int>::argument_type r5;      // NON_COMPLIANT
  std::function<int(int)>::result_type r6; // NON_COMPLIANT
  std::function<int(int)> f;               // COMPLIANT
}

#include <strstream>

void f13(std::strstreambuf *sb) { // NON_COMPLIANT
  std::istrstream is("hello");    // NON_COMPLIANT
  std::ostrstream os;             // NON_COMPLIANT
  std::strstream ss;              // NON_COMPLIANT
}

#include <iterator>

// NON_COMPLIANT - inherits from deprecated std::iterator base class
struct MyIter : std::iterator<std::forward_iterator_tag, int> {
  int &operator*();
  MyIter &operator++();
  bool operator==(const MyIter &) const;
};

// COMPLIANT - defines iterator typedefs directly without inheriting
// std::iterator
struct MyIter2 {
  using iterator_category = std::forward_iterator_tag;
  using value_type = int;
  using difference_type = std::ptrdiff_t;
  using pointer = int *;
  using reference = int &;
  int &operator*();
  MyIter2 &operator++();
  bool operator==(const MyIter2 &) const;
};

int f14_helper(int x);

void f14() {
  std::hash<int>::result_type h1;   // NON_COMPLIANT
  std::hash<int>::argument_type h2; // NON_COMPLIANT
  auto b = std::bind(f14_helper, 1);
  decltype(b)::result_type b1; // NON_COMPLIANT
  auto m = std::mem_fn(f14_helper);
  decltype(m)::result_type m1; // NON_COMPLIANT
}

void n1() throw() {} // NON_COMPLIANT - deprecated throw() specifier
// void n2() throw(std::exception) {} invalid in C++17
void n3() noexcept {} // COMPLIANT - noexcept is the correct specifier
void n4() {}          // COMPLIANT - no exception specifier