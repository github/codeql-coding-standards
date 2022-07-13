// Header.hpp
namespace // Non-compliant
{
  extern int32_t x;
}
// File1.cpp
#include "Header.hpp"
namespace
{
  int32_t x;
}
void fn_a(void)
{
  x = 24;
}
// File2.cpp
#include "Header.hpp"
namespace
{
  int32_t x;
}
void fn_b(void)
{
  fn_a();
  if(x == 24) // This x will not have been initialized.
  {
  } 
}