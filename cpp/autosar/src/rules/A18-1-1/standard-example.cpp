// $Id: A18-1-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <algorithm> 
#include <array> 
#include <cstdint> 
void Fn() noexcept
{
  const std::uint8_t size = 10;
  std::int32_t a1[size]; // Non-compliant
  std::array<std::int32_t, size> a2; // Compliant
  // ...
  std::sort(a1, a1 + size);
  std::sort(a2.begin(), a2.end()); // More readable and maintainable way of
                                   // working with STL algorithms
}
class A 
{ 
  public:
    static constexpr std::uint8_t array[]{0, 1, 2}; // Compliant by exception 
};