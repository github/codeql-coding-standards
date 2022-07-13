// $Id: A8-5-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <initializer_list>
void F1() noexcept
{
  std::int32_t x1 =
         7.9; // Non-compliant - x1 becomes 7 without compilation error
  // std::int32_t y {7.9}; // Compliant - compilation error, narrowing 
  std::int8_t x2{50};    // Compliant
  std::int8_t x3 = {50}; // Non-compliant - std::int8_t x3 {50} is equivalent
                         // and more readable
  std::int8_t x4 =
         1.0; // Non-compliant - implicit conversion from double to std::int8_t
  std::int8_t x5 = 300; // Non-compliant - narrowing occurs implicitly 
  std::int8_t x6(x5);   // Non-compliant
}
class A 
{
  public:
    A(std::int32_t first, std::int32_t second) : x{first}, y{second} {}
  private: 
    std::int32_t x; 
    std::int32_t y;
};
struct B {
  std::int16_t x;
  std::int16_t y; 
};
class C {
  public:
    C(std::int32_t first, std::int32_t second) : x{first}, y{second} {} 
    C(std::initializer_list<std::int32_t> list) : x{0}, y{0} {}

  private: 
    std::int32_t x; 
    std::int32_t y;
};
void F2() noexcept 
{
  A a1{1, 5};    // Compliant - calls constructor of class A
  A a2 = {1, 5}; // Non-compliant - calls a default constructor of class A
                 // and not copy constructor or assignment operator.
  A a3(1, 5);    // Non-compliant
  B b1{5, 0};    // Compliant - struct members initialization
  C c1{2, 2};    // Compliant - C(std::initializer_list<std::int32_t>)
                 // constructor is called
  C c2(2, 2);    // Compliant by exception - this is the only way to call 
                 // C(std::int32_t, std::int32_t) constructor
  C c3{{}};      // Compliant - C(std::initializer_list<std::int32_t>) constructor 
                 // is called with an empty initializer_list 
  C c4({2, 2});  // Compliant by exception - C(std::initializer_list<std::int32_t>) 
                 // constructor is called
};
template <typename T, typename U> 
void F1(T t, U u) noexcept(false)
{
  std::int32_t x = 0;
  T v1(x); // Non-compliant
  T v2{x}; // Compliant - v2 is a variable
  // auto y = T(u); // Non-compliant - is it construction or cast? 
  // Compilation error
};
void F3() noexcept 
{
  F1(0, "abcd"); // Compile-time error, cast from const char* to int 
}