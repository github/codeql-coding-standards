#include <type_traits>

template <typename T> class A { // COMPLIANT

  static_assert(std::is_trivially_copy_constructible<T>::value,
                "Given template type is not copy constructible.");

  static_assert(std::is_trivially_copy_assignable<T>(),
                "Given template type is not copy assignable.");

  static_assert(std::is_trivially_move_constructible<T>(),
                "Given template type is not move constructible.");

  static_assert(std::is_trivially_move_assignable<T>(),
                "Given template type is not move assignable.");

public:
  A() = default;
  A(A const &) = default;
  A &operator=(A const &) = default;
  A(A &&) = default;
  A &operator=(A &&) = default;

private:
  T a;
};

template <typename T> class B { // NON_COMPLIANT
public:
  B() = default;
  B(B const &) = default;
  B &operator=(B const &) = default;
  B(B &&) = default;
  B &operator=(B &&) = default;

private:
  T b;
};

class C { // COMPLIANT
  // (didnt need to check)
public:
  C() = default;
  C(C const &) = default;
  C &operator=(C const &) = default;
  C(C &&) = default;
  C &operator=(C &&) = default;
};

void f() { A<C> a; }