//% $Id: A1-1-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <stdexcept>
void F(std::int32_t i)
{
  std::int32_t* a = nullptr;

  // __try // Non-compliant - __try is a part of Visual Studio extension
  try // Compliant - try keyword is a part of C++ Language Standard
  {
    a = new std::int32_t[i];
    // ...
  }

  // __finally // Non-compliant - __finally is a part of Visual Studio
  // extension
  catch (
    std::exception&) // Compliant - C++ Language Standard does not define
                     //             finally block, only try and catch blocks
  {
    delete[] a;
    a = nullptr;
  }
}