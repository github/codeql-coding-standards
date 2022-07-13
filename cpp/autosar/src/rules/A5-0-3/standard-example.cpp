// $Id: A5-0-3.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
using IntPtr = std::int8_t *;
struct S {
  std::int8_t *s1;   // Compliant
  std::int8_t **s2;  // Compliant
  std::int8_t ***s3; // Non-compliant
};
S *ps1;   // Compliant
S **ps2;  // Compliant
S ***ps3; // Non-compliant

std::int8_t **(*pfunc1)();   // Compliant
std::int8_t **(**pfunc2)();  // Compliant
std::int8_t **(***pfunc3)(); // Non-compliant
std::int8_t ***(**pfunc4)(); // Non-compliant

void Fn(std::int8_t *par1,         // Compliant
        std::int8_t **par2,        // Compliant
        std::int8_t ***par3,       // Non-compliant
        IntPtr *par4,              // Compliant
        IntPtr *const *const par5, // Non-compliant
        std::int8_t *par6[],       // Compliant
        std::int8_t **par7[])      // Non-compliant
{
  std::int8_t *ptr1;                   // Compliant
  std::int8_t **ptr2;                  // Compliant
  std::int8_t ***ptr3;                 // Non-compliant
  IntPtr *ptr4;                        // Compliant
  IntPtr *const *const ptr5 = nullptr; // Non-compliant
  std::int8_t *ptr6[10];               // Compliant
  std::int8_t **ptr7[10];              // Compliant
}
// Explanation of types
// 1) par1 and ptr1 are of type pointer to std::int8_t.
// 2) par2 and ptr2 are of type pointer to pointer to std::int8_t.
// 3) par3 and ptr3 are of type pointer to a pointer to a pointer
// to std::int8_t.
// This is three levels and is non-compliant.
// 4) par4 and ptr4 are expanded to a type of pointer to a pointer to
// std::int8_t.
// 5) par5 and ptr5 are expanded to a type of const pointer to a const
// pointer
// to a pointer to std::int8_t. This is three levels and is non-compliant.
// 6) par6 is of type pointer to pointer to std::int8_t because arrays
// are converted
// to a pointer to the initial element of the array.
// 7) ptr6 is of type pointer to array of std::int8_t.
// 8) par7 is of type pointer to pointer to pointer to
// std::int8_t because arrays are
// converted to a pointer to the initial element of the array. This is
// three
// levels and is non-compliant.
// 9) ptr7 is of type array of pointer to pointer to std::int8_t. This
// is compliant.