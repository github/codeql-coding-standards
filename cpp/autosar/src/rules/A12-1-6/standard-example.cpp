// $Id: A12-1-6.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
class A
{
  public:
    A(std::int32_t x, std::int32_t y) : x(x + 8), y(y) {}
    explicit A(std::int32_t x) : A(x, 0) {}
  
  private: 
    std::int32_t x; std::int32_t y;
};

// Non-compliant
class B : public A 
{
  public:
    B(std::int32_t x, std::int32_t y) : A(x, y) {} 
    explicit B(std::int32_t x) : A(x) {}
};

// Compliant
class C : public A 
{
  public:
    using A::A;
};