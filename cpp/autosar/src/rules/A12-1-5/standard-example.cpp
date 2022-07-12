// $Id: A12-1-5.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
class A
{
  private: 
    std::int32_t x; 
    std::int32_t y;
};
class B {
  public:
    // Non-compliant
    B(std::int32_t x, std::int32_t y) : x(x + 8), y(y) {} 
    explicit B(std::int32_t x) : x(x + 8), y(0) {}

  private: 
    std::int32_t x; 
    std::int32_t y;
};