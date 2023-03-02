struct A {};

struct B {

  // implicit conversion
  operator A() const { return A(); }

  // explicit conversion
  explicit operator A *() const { return 0; }

  A AsA() { return A(); }
  using array_A = A[3];
  operator array_A *() const; // conversion to pointer A to any type
};

extern void foo(A const &);
extern void bar(A *); // pointer

// extern void bar(*pa[3]);
struct C {
  template <typename T>
  operator T *() const; // conversion to pointer to any type
};

// out-of-class definition
template <typename T> C::operator T *() const { return nullptr; }

// explicit specialization for char*
template <> C::operator A *() const { return 0; }

int main() {
  B b;
  foo(b);                   // NON_COMPLIANT function call
  foo(b.AsA());             // COMPLIANT method call
  bar(static_cast<A *>(b)); // NON_COMPLIANT--explicit

  A(*pa)[3] = b; //   NON_COMPLIANT - converting B to array of A (size 3)-
  // declaration of variable name pa, pointer to array of A , array size is 3

  C c;
  bar(c); // NON_COMPLIANT - one pointer with bar
}
