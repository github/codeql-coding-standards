// $Id: A7-1-3.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
using IntPtr = std::int32_t*;
using IntConstPtr = std::int32_t* const;
using ConstIntPtr = const std::int32_t*;
void Fn(const std::uint8_t& input) // Compliant
{
  std::int32_t value1 = 10; 
  std::int32_t value2 = 20;

  const IntPtr ptr1 =
      &value1; // Non-compliant - deduced type is std::int32_t*
               // const, not const std::int32_t*
  // ptr1 = &value2; // Compilation error, ptr1 is read-only variable

  IntPtr const ptr2 =
      &value1; // Compliant - deduced type is std::int32_t* const

  // ptr2 = &value2; // Compilation error, ptr2 is read-only variable

  IntConstPtr ptr3 = &value1; // Compliant - type is std::int32_t* const, no 
                              // additional qualifiers needed

  // ptr3 = &value2; // Compilation error, ptr3 is read-only variable
 
  ConstIntPtr ptr4 = &value1; // Compliant - type is const std::int32_t*

  const ConstIntPtr ptr5 = &value1; // Non-compliant, type is const 
                                    // std::int32_t* const, not const const
                                    // std::int32_t* 
  ConstIntPtr const ptr6 =
      &value1; // Compliant - type is const std::int32_t* const
 }