// NON_COMPLIANT: Cannot #include fenv.h.
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
  fenv_t env;
  fegetenv(&env);
  fesetenv(&env);    // NON_COMPLIANT
  feupdateenv(&env); // NON_COMPLIANT
  fesetround(0);     // NON_COMPLIANT
  f2();              // COMPLIANT
}
