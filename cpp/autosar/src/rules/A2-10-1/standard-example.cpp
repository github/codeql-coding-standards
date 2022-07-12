//% $Id: A2-10-1.cpp 313834 2018-03-27 11:35:19Z michal.szczepankiewicz $
#include <cstdint>
std::int32_t sum = 0;
namespace
{
  std::int32_t sum; // Non-compliant, hides sum in outer scope
}
class C1
{
  std::int32_t sum; // Compliant, does not hide sum in outer scope 
};
namespace n1 
{
  std::int32_t sum; // Compliant, does not hide sum in outer scope 
  namespace n2
  {
    std::int32_t sum; // Compliant, does not hide sum in outer scope 
  }
}

std::int32_t idx;
void F1(std::int32_t idx) 
{
  //Non-compliant, hides idx in outer scope
}

void F2() 
{
  std::int32_t max = 5;
  
  for (std::int32_t idx = 0; idx < max;
       ++idx) // Non-compliant, hides idx in outer scope
  {
    for (std::int32_t idx = 0; idx < max;
         ++idx) // Non-compliant, hides idx in outer scope
    {
    }
  }
}

void F3() 
{
  std::int32_t i = 0; 
  std::int32_t j = 0; 
  auto lambda = [i]() {
    std::int32_t j =
              10; // Compliant - j was not captured, so it does not hide
                  // j in outer scope
    return i + j; 
  };
}