for(x = 0; (x < 10) && (u8a != 3U); ++x) // Non-compliant
{
  uint8_a = fn();
}
for(x = 0; (x < 10) && flag; ++x)        // Compliant
{
  u8a = fn();
  flag = u8a != 3U;
}