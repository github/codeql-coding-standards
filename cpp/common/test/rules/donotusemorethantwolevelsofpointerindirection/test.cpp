#include <cstdint>
using IntPtr = std::int16_t *;

using std::int16_t;
struct S {
  std::int16_t *s1;    // COMPLIANT
  std::int16_t **s2;   // COMPLIANT
  std::int16_t ***s3;  // NON_COMPLIANT
  std::int16_t ****s4; // NON_COMPLIANT
};

S *ps1;    // COMPLIANT
S **ps2;   // COMPLIANT
S ***ps3;  // NON_COMPLIANT
S ****ps4; // NON_COMPLIANT

std::int16_t **(*ptfunc1)();    // COMPLIANT
std::int16_t **(**ptfunc2)();   // COMPLIANT
std::int16_t **(***ptfunc3)();  // NON_COMPLIANT
std::int16_t ***(**ptfunc4)();  // NON_COMPLIANT
std::int16_t ***(***ptfunc5)(); // NON_COMPLIANT

void f(std::int16_t *par1,        // COMPLIANT
       std::int16_t **par2,       // COMPLIANT
       std::int16_t ***par3,      // NON_COMPLIANT
       IntPtr *par4,              // COMPLIANT
       IntPtr *const *const par5, // NON_COMPLIANT
       std::int16_t *par6[],      // COMPLIANT
       std::int16_t **par7[]      // NON_COMPLIANT
)

{
  std::int16_t *ptr1;                  // COMPLIANT
  std::int16_t **ptr2;                 // COMPLIANT
  std::int16_t ***ptr3;                // NON_COMPLIANT
  std::int16_t ****ptr4;               // NON_COMPLIANT
  IntPtr *ptr8;                        // COMPLIANT
  IntPtr *const *const ptr5 = nullptr; // NON_COMPLIANT
  std::int16_t *ptr6[10];              // COMPLIANT
  std::int16_t **ptr7[10];             // COMPLIANT
}