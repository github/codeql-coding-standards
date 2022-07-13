// $Id: A6-5-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <iterator>
void Fn() noexcept
{
  constexpr std::int8_t arraySize = 7;
  std::uint32_t array[arraySize] = {0, 1, 2, 3, 4, 5, 6};

  for (std::int8_t idx = 0; idx < arraySize; ++idx) // Compliant 
  {
    array[idx] = idx; 
  }
  
  for (std::int8_t idx = 0; idx < arraySize / 2;
       ++idx) // Compliant - for does not loop though all elements
  {
    // ... 
  }

  for (std::uint32_t* iter = std::begin(array); iter != std::end(array); 
       ++iter) // Non-compliant
  {
    // ... 
  }

  for (std::int8_t idx = 0; idx < arraySize; ++idx) // Non-compliant 
  {
    // ... 
  }

  for (std::uint32_t value :
       array) // Compliant - equivalent to non-compliant loops above
  {
    // ... 
  }

  for (std::int8_t idx = 0; idx < arraySize; ++idx) // Compliant 
  {
    if ((idx % 2) == 0) 
    {
      // ... 
    }
  } 
}