#include <cstdlib>
#include <cerrno>
void f1(const char_t * str)
{
  errno=0; // Non-compliant
  int32_t i = atoi(str);
  if(0 != errno) // Non-compliant
  {
    // handle error case???
  } 
}