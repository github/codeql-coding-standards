// $Id: A6-4-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
void F1(std::uint8_t choice) noexcept
{
  switch (choice)
  {
    default: 
      break;
  } // Non-compliant, the switch statement is redundant 
}
void F2(std::uint8_t choice) noexcept 
{
  switch (choice) 
  {
    case 0:
      // ...
      break;
    default: // ...
      break;
  } // Non-compliant, only 1 case-clause

  if (choice == 0) // Compliant, an equivalent if statement 
  {
    // ... 
  }
  else
  {
    // ... 
  }

  // ...
  switch (choice) 
  {
    case 0:
      // ...
      break;
    case 1:
      // ...
      break;
    default: 
      // ...
      break; 
  } // Compliant
}