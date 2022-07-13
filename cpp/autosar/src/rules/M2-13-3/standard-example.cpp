template <typename T>
void f ( T );
template <>
void f < uint16_t > ( uint16_t );
template <>
void f < int16_t > ( int16_t );
void b ( )
{
  uint16_t u16a = 0U;   // Compliant
  f ( 0x8000 );         // Non-compliant on a 16-bit platform.
  u16a = u16a + 0x8000; // Non-compliant as context is unsigned.
}