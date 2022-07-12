// $Id: A27-0-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <iostream> 
#include <string> 
void F1() noexcept
{
  char buffer[10];
  std::cin >> buffer; // Non-compliant - this could lead to a buffer overflow 
}
void F2() noexcept
{
  std::string string1;
  std::string string2;
  std::cin >> string1 >> string2; // Compliant - no buffer overflows 
}
void F3(std::istream& in) noexcept
{
  char buffer[32];

  try
  {
    in.read(buffer, sizeof(buffer));
  }
  catch (std::ios_base::failure&)
  {
    // Handle an error
  }

  std::string str(buffer); // Non-compliant - if ’buffer’ is not null
  // terminated, then constructing std::string leads
  // to undefined behavior.
}
void F4(std::istream& in) noexcept 
{
  char buffer[32];
  try
  {
    in.read(buffer, sizeof(buffer));
  }
  catch (std::ios_base::failure&)
  {
    // Handle an error
  }

  std::string str(buffer, in.gcount()); // Compliant 
}