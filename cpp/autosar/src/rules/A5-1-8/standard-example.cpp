// $Id: A5-1-8.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
void Fn1()
{
  std::int16_t x = 0; 
  auto f1 = [&x]() {
    auto f2 = []() {}; // Non-compliant f2();
    auto f4 = []() {}; // Non-compliant f4();
  }; // Non-compliant
  
  f1();
}
void Fn2()
{
  auto f5 = []() {
    // Implementation
  }; // Compliant
  f5();
}