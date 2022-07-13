// $Id: A12-8-7.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint> 
class A
{
  public:
    A() = default;
    A& operator*=(std::int32_t i) // Non-compliant
    {
      // ...
      return *this; 
    }
};
A F1() noexcept 
{
  return A{}; 
}
class B 
{
  public:
  B() = default;
  B& operator*=(std::int32_t) & // Compliant 
  {
    // ...
    return *this; 
  }
};
B F2() noexcept 
{
  return B{}; 
}
std::int32_t F3() noexcept 
{
  return 1; 
}
int main(int, char**) 
{
  F1() *= 10; // Temporary result of f1() multiplied by 10. No compile-time 
              // error.
  ;
  // f2() *= 10; // Compile-time error due to ref-qualifier 
  ;
  // f3() *= 10; // Compile-time error on built-in type
}