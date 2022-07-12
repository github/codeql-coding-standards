#include <utility> 
class A
{
  public:
    A() = default;
    ~A() = default;
    A(A const&) = delete;
    A& operator=(A const&) = delete;
    A(A&&) = delete;
    A& operator=(A&&) = delete;
};
class B
{
  public:
    B() = default;
    B(B const&) = default;
    B& operator=(B const&) = default; B(B&&) = default;
    B& operator=(B&&) = default;
};
template <typename T>
void F1(T const& obj) noexcept(false)
{
  static_assert(std::is_copy_constructible<T>(),
                "Given template type is not copy constructible."); // Compliant 
}
template <typename T>
class C
{
  // Compliant 
  static_assert(std::is_trivially_copy_constructible<T>(),
                "Given template type is not trivially copy constructible.");

  // Compliant
  static_assert(std::is_trivially_move_constructible<T>(),
                "Given template type is not trivially move constructible.");
  
  // Compliant
  static_assert(std::is_trivially_copy_assignable<T>(),
                "Given template type is not trivially copy assignable.");

  // Compliant
  static_assert(std::is_trivially_move_assignable<T>(),
                "Given template type is not trivially move assignable.");

  public:
    C() = default;
    C(C const&) = default;
    C& operator=(C const&) = default;
    C(C&&) = default;
    C& operator=(C&&) = default;

  private:
    T c;
};

template <typename T>
class D
{
  public:
    D() = default;
    D(D const&) = default;            // Non-compliant - T may not be copyable 
    D& operator=(D const&) = default; // Non-compliant - T may not be copyable
    D(D&&) = default;                 // Non-compliant - T may not be movable 
    D& operator=(D&&) = default;      // Non-compliant - T may not be movable

  private:
    T d;
};

void F2() noexcept
{
  A a;
  B b;
  // f1<A>(a); // Class A is not copy constructible, compile-time error
  // occurs
  F1<B>(b); // Class B is copy constructible
  // C<A> c1; // Class A can not be used for template class C, compile-time 
  // error occurs
  C<B> c2; // Class B can be used for template class C
  D<A> d1;
  // D<A> d2 = d1; // Class D can not be copied, because class A is not
  // copyable, compile=time error occurs
  // D<A> d3 = std::move(d1); // Class D can not be moved, because class A is 
  // not movable, compile-time error occurs
  D<B> d4;
  D<B> d5 = d4;
  D<B> d6 = std::move(d4);
}