#include <cstdint>

void f() {

  std::uint8_t foo = 0x9DU;

  std::uint8_t result_8;

  std::uint16_t result_16;

  std::uint16_t mode;

  result_8 = (std::uint8_t)(~foo);                      // COMPLIANT
  result_8 = std::uint8_t(~foo);                        // COMPLIANT
  result_8 = (std::uint8_t)((std::uint8_t)(~foo)) << 2; // COMPLIANT
  result_16 = (static_cast<std::uint16_t>(~foo)) >> 6;  // COMPLIANT
  result_8 = (std::uint64_t)(~foo);                     // NON_COMPLIANT
  result_8 = ((std::uint8_t)(~foo)) << 2;               // NON_COMPLIANT
  result_8 = (~foo) >> 4;                               // NON_COMPLIANT
  result_16 = ((foo << 4) & mode) >> 6;                 // NON_COMPLIANT
  result_16 =
      (static_cast<std::uint16_t>(static_cast<std::uint16_t>(foo) << 4) &
       mode) >>
      6; // NON_COMPLIANT
}