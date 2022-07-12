//% $Id: A2-13-5.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <cstdint>

int main(void)
{
  std::int16_t a = 0x0f0f; //non-compliant 
  std::int16_t b = 0x0f0F; //non-compliant 
  std::int16_t c = 0x0F0F; //compliant

  return 0; 
}