// $Id: A2-3-1.cpp 307578 2018-02-14 14:46:20Z michal.szczepankiewicz $
#include <cstdint>
void Fn() noexcept
{
  std::int32_t sum = 0; // Compliant
  // std::int32_t Â£_value = 10; // Non-compliant
  // sum += Â£_value; // Non-compliant
  // Variable sum stores Â£ pounds // Non-compliant
}