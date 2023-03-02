#include <fenv.h>
void f2();
void f1() {
  int i = feclearexcept(FE_INVALID); // NON_COMPLIANT
  fexcept_t i2;
  fegetexceptflag(&i2, FE_ALL_EXCEPT); // NON_COMPLIANT
  feraiseexcept(FE_DIVBYZERO);         // NON_COMPLIANT
  feraiseexcept(FE_OVERFLOW);          // NON_COMPLIANT
  fesetexceptflag(&i2, FE_ALL_EXCEPT); // NON_COMPLIANT
  fetestexcept(FE_UNDERFLOW);          // NON_COMPLIANT
  f2();                                // COMPLIANT
}
