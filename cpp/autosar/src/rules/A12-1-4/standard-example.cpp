// $Id: A12-1-4.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
class A
{
  public:
    explicit A(std::int32_t number) : x(number) {} // Compliant
    A(A const&) = default;
    A(A&&) = default;
    A& operator=(A const&) = default;
    A& operator=(A&&) = default;
  private:
    std::int32_t x;
};
class B
{
  public:
    B(std::int32_t number) : x(number) {} // Non-compliant
    B(B const&) = default;
    B(B&&) = default;
    B& operator=(B const&) = default;
    B& operator=(B&&) = default;

  private:
    std::int32_t x;
};
void F1(A a) noexcept
{
}
void F2(B b) noexcept
{
}
void F3() noexcept
{
  F1(A(10));
  // f1(10); // Compilation error - because of explicit constructor it is not
             // possible to implicitly convert integer
             // to type of class A
  F2(B(20));
  F2(20); // No compilation error - implicit conversion occurs
}