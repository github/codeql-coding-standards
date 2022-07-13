// $Id: A5-16-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
constexpr bool Fn1(std::int32_t x)
{
  return (x > 0); // Compliant
}
std::int32_t Fn2(std::int32_t x)
{
  std::int32_t i = (x >= 0 ? x : 0); // Compliant 
  std::int32_t j = x + (i == 0 ? (x >= 0 ? x : -x) : i); // Non-compliant - nested
                                                         // conditional operator
                                                         // and used as a 
                                                         // sub-expression
  return (
    i >0
        ? (j > 0 ? i + j : i)
        : (j > 0 ? j : 0)); // Non-compliant - nested conditional operator
}