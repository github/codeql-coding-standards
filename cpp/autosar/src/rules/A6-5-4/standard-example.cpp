// $Id: A6-5-4.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <cstdint>
void Fn() noexcept
{
  for(std::int32_t x = 0, MAX=10; x < MAX; x++) // compliant with A6-5-2, but 
                                                // non-compliant with advisory A6-5-4
  {
    // ... 
  }
}