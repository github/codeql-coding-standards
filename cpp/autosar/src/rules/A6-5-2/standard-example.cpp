// $Id: A6-5-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
namespace
{
  constexpr std::int32_t xlimit = 20;
  constexpr std::int32_t ylimit = 15;
  constexpr float zlimit = 2.5F;
  constexpr std::int32_t ilimit = 100;
}
void Fn() noexcept 
{
  std::int32_t y = 0;

  for (std::int32_t x = 0; x < xlimit && y < ylimit;
       x++, y++) // Non-compliant, two loop-counters
  {
    // ... 
  }

  for (float z = 0.0F; z != zlimit;
       z += 0.1F) // Non-compliant, float with !=
  {
    // ... 
  }

  for (float z = 0.0F; z < zlimit; z += 0.1F) // Non-compliant, float with < 
  {
    // ... 
  }

  for (std::int32_t i = 0; i < ilimit; ++i) // Compliant 
  {
    // ... 
  }
}