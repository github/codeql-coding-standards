extern void f1(int i);
extern int g1; // COMPLIANT
extern int g2; // NON_COMPLIANT; single use of a global variable
bool f2() { return g1 == 1; }
void f3() {
  int j = g1; // NON_COMPLIANT
  if (f2()) {
    int k; // COMPLIANT
    f1(j);
    f1(k);
  }
}

void f4() {
  int j = g1; // COMPLIANT; value of g1 changed between
              // definition and use
  g1 = 1;
  if (f2()) {
    f1(j);
  }
}

void f5() {
  int j = g1; // COMPLIANT; shouldn't be moved inside loop
  while (true) {
    int i = g1++;
    while (f2()) {
      i += j;
    }

    if (i % 2)
      break;
  }
}

void f6() {
  int j = g1; // COMPLIANT; can't moved into smaller scope
#ifdef FOO
  if (g1) {
    g1 = j + 1;
  }
#else
  if (g1) {
    g1 = j + 2;
  }
#endif
}

void f7() {
  int j = g1; // COMPLIANT; potentially stores previous value of
              // g1 so moving this would be incorrect.
  f1(1);      // f1 may change the value of g1
  if (f2()) {
    f1(j);
  }
}

void f8() { int i = g2; }

void f9() {
  int i; // NON_COMPLIANT

  if (f2()) {
    if (f2()) {
      i++;
    } else {
      i--;
    }
  }
}

struct S1 { // NON_COMPLIANT
  int i;
};

void f10() { S1 l1{}; }

void f11() {
  struct S2 { // COMPLIANT
    int i;
  } l1{};
}

struct S3 {
  int i;
};

template <typename T> int f12(T p);
template <> int f12(S3 p) { return p.i; }

struct S4 { // NON_COMPLIANT; single use in function f13
  int i;
};

template <typename T> class C1 { // COMPLIANT; used in both f13 and f14
private:
  T m1;
};

void f13() { C1<S4> l1; }
void f14() { C1<int> l1; }

void f15() {
  int i; // COMPLIANT

  if (i == 0) {
    i++;
  }
}

namespace ns1 {
int i; // NON_COMPLIANT
namespace ns2 {
int j = i + 1;
void f1() { i++; }
} // namespace ns2
} // namespace ns1

void f16() {
  for (int i = 0; i < 10; i++) {
    int j = i + 1; // NON_COMPLIANT[FALSE_NEGATIVE]; we are not consider
                   // candidates inside loops.
    try {
      j++;
    } catch (...) {
    }
  }
}

void f17() {
  int i; // COMPLIANT
  int *ptr;
  {
    // Moving the declaration of i into the reduced scope will result in a
    // dangling pointer
    ptr = &i;
  }
  *ptr = 1;
}

namespace a_namespace {

constexpr static unsigned int a_constexpr_var{
    10U}; // COMPLIANT; used in
          // a_namespace and
          // another_namespace_function
static unsigned int
    a_namespace_var[a_constexpr_var]{}; // COMPLIANT; used in
                                        // a_namespace_function and
                                        // another_namespace_function

constexpr static unsigned int a_namespace_function(void) noexcept {
  unsigned int a_return_value{0U};

  for (auto loop_var : a_namespace_var) { // usage of a_namespace_var
    a_return_value += loop_var;
  }
  return a_return_value;
}

constexpr static unsigned int another_namespace_function(void) noexcept {
  unsigned int a_return_value{0U};

  for (unsigned int i{0U}; i < a_constexpr_var;
       i++) {                             // usage of a_constexpr_var
    a_return_value += a_namespace_var[i]; // usage of a_namespace_var
  }
  return a_return_value;
}
} // namespace a_namespace

namespace parent_namespace {
namespace child_namespace {
template <typename From> class a_class_in_child_namespace {
public:
  template <typename To> constexpr auto &&operator()(To &&val) const noexcept {
    return static_cast<To>(val);
  }
}; // a_class_in_child_namespace end

template <typename From>
extern constexpr a_class_in_child_namespace<From>
    a_class_in_child_namespace_impl{};

} // namespace child_namespace

template <typename From>
static constexpr auto const &a_parent_namespace_variable =
    child_namespace::a_class_in_child_namespace_impl<
        From>; // COMPLIANT; used in child_namespace2::a_class::bar() and
               // parent_namespace::another_class::foo()

namespace child_namespace2 {
class a_class {
public:
  int func(...) { return 0; }
  void foo(int x) { x++; }
  template <typename F> constexpr auto bar(F(*func), int b) {
    foo(func(a_parent_namespace_variable<F>(
        b))); // usage of a_parent_namespace_variable
  }
}; // a_class
} // namespace child_namespace2

class another_class {
  int a;
  int b;
  void bar(int param) { param++; }

  bool has_value() { return a == b; }

public:
  template <typename F> int foo(F(*func), int b) {
    if (has_value()) {
      bar(func(a_parent_namespace_variable<F>(
          b))); // usage of a_parent_namespace_variable
    }
    return 0;
  }
}; // another_class
} // namespace parent_namespace

template <typename T> T a_func(T v) { return v++; }

int main() {
  parent_namespace::child_namespace2::a_class a_class_obj;
  a_class_obj.bar(a_func<int>, 10);
  parent_namespace::another_class another_class_obj;
  another_class_obj.foo(a_func<int>, 10);
  return 0;
}
