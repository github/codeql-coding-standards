// $Id: A2-7-2.cpp 305382 2018-01-26 06:32:15Z michal.szczepankiewicz $
#include <cstdint>
void Fn1() noexcept
{
  std::int32_t i = 0;
    ///*
    // /* ++i; /* incrementing the variable i */
    // * // Non-compliant - C-style comments nesting is not supported,
    // compilation error
  for (; i < 10; ++i) {
    // ...  
  }
}
void Fn2() noexcept 
{
  std::int32_t i = 0;
  // ++i; // Incrementing the variable i // Non-compliant - code should not 
  // be commented-out
  for (; i < 10; ++i)
  {
    // ... }
  }
}
void Fn3() noexcept 
{
  std::int32_t i = 0;
  ++i; // Incrementing the variable i using ++i syntax // Compliant - code
       // is not commented-out, but ++i occurs in a
       // comment too
  for (; i < 10; ++i) 
  {
    // ... 
  }
}