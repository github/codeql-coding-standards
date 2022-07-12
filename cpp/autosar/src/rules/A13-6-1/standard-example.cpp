// $Id: A13-6-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint> 
void Fn() noexcept
{
  std::uint32_t decimal1 = 3'000'000;   // Compliant
  std::uint32_t decimal2 = 4'500;       // Compliant
  std::uint32_t decimal3 = 54'00'30;    // Non-compliant
  float decimal4 = 3.141'592'653;       // Compliant
  float decimal5 = 3.1'4159'265'3;      // Non-compliant
  std::uint32_t hex1 = 0xFF'FF'FF'FF;   // Compliant
  std::uint32_t hex2 = 0xFAB'1'FFFFF;   // Non-compliant
  std::uint8_t binary1 = 0b1001'0011;   // Compliant
  std::uint8_t binary2 = 0b10'00'10'01; // Non-compliant 
}