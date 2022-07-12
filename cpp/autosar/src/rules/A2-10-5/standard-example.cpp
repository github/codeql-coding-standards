//% $Id: A2-10-5.cpp 305382 2018-01-26 06:32:15Z michal.szczepankiewicz $
#include <cstdint>
// f1.cpp
namespace n_s1
{
  static std::int32_t globalvariable = 0;
}
static std::int32_t filevariable = 5;        // Compliant - identifier not reused
static void Globalfunction();

// f2.cpp
namespace n_s1
{
  // static std::int32_t globalvariable = 0; // Non-compliant - identifier reused
  static std::int16_t modulevariable = 10;   // Compliant - identifier not reused
}
namespace n_s2
{
  static std::int16_t modulevariable2 = 20;
}
static void Globalfunction();                // Non-compliant - identifier reused
static std::int16_t modulevariable2 = 15;    // Non-compliant - identifier reused