#include <cstdint>

void signed_arg(std::uint32_t s);
void unsigned_arg(std::uint32_t u);

void f() {
  using std::int16_t;
  using std::int32_t;
  using std::int8_t;
  using std::uint16_t;
  using std::uint32_t;
  using std::uint8_t;

  int8_t i8;
  int16_t i16;
  int32_t i32;
  uint8_t u8;
  uint16_t u16;
  uint32_t u32;
  i8 = static_cast<int8_t>(u8 + u8); // NON_COMPLIANT

  i8 = static_cast<int8_t>(u8 + u8 + u8); // NON_COMPLIANT

  i8 = static_cast<int8_t>(u8 * u8); // NON_COMPLIANT

  i16 = static_cast<int16_t>(i16 / i8); // NON_COMPLIANT

  i8 = static_cast<int8_t>(u8) + static_cast<int8_t>(u8); // COMPLIANT

  unsigned(static_cast<uint32_t>(i32)); // COMPLIANT - i32 is not a cvalue
  signed(static_cast<int32_t>(u32));    // COMPLIANT - u32 is not a cvalue
}