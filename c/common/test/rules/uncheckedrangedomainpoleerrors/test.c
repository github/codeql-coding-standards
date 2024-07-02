#include <limits.h>
#include <math.h>
#include <stdlib.h>

void test_domain_errors() {
  acos(-1.1f);       // NON_COMPLIANT
  acos(-1.0f);       // COMPLIANT
  acos(0.0f);        // COMPLIANT
  acos(1.0f);        // COMPLIANT
  acos(1.1f);        // NON_COMPLIANT
  asin(-1.1f);       // NON_COMPLIANT
  asin(-1.0f);       // COMPLIANT
  asin(0.0f);        // COMPLIANT
  asin(1.0f);        // COMPLIANT
  asin(1.1f);        // NON_COMPLIANT
  atanh(-1.1f);      // NON_COMPLIANT
  atanh(0.0f);       // COMPLIANT
  atanh(1.1f);       // NON_COMPLIANT
  atan2(0.0f, 0.0f); // NON_COMPLIANT
  atan2(1.0f, 0.0f); // COMPLIANT
  atan2(0.0f, 1.0f); // COMPLIANT
  atan2(1.0f, 1.0f); // COMPLIANT
  pow(0.0f, 0.0f);   // NON_COMPLIANT
  pow(1.0f, 0.0f);   // COMPLIANT
  pow(0.0f, 1.0f);   // COMPLIANT
  pow(1.0f, 1.0f);   // COMPLIANT
  pow(-1.0f, -1.0f); // NON_COMPLIANT
  pow(-1.0f, 0.0f);  // COMPLIANT
  pow(1.0f, -1.0f);  // COMPLIANT
  pow(-1.0f, 1.0f);  // COMPLIANT
  acosh(1.0f);       // COMPLIANT
  acosh(0.9f);       // NON_COMPLIANT
  ilogb(0.0f);       // NON_COMPLIANT
  ilogb(1.0f);       // COMPLIANT
  ilogb(-1.0f);      // COMPLIANT
  log(-1.0f);        // NON_COMPLIANT
  log(1.0f);         // COMPLIANT
  log10(-1.0f);      // NON_COMPLIANT
  log10(1.0f);       // COMPLIANT
  log2(-1.0f);       // NON_COMPLIANT
  log2(1.0f);        // COMPLIANT
  sqrt(-1.0f);       // NON_COMPLIANT
  sqrt(0.0f);        // COMPLIANT
  sqrt(1.0f);        // COMPLIANT
  log1p(-2.0f);      // NON_COMPLIANT
  log1p(0.0f);       // COMPLIANT
  logb(0.0f);        // NON_COMPLIANT
  logb(1.0f);        // COMPLIANT
  logb(-1.0f);       // COMPLIANT
  tgamma(0.0f);      // NON_COMPLIANT
  tgamma(1.0f);      // COMPLIANT
  tgamma(-1.1f);     // COMPLIANT
}

void fn_in_193_missing_domain_or_range_cases() {
  abs(INT_MIN);     // NON_COMPLIANT
  fmod(1.0f, 0.0f); // NON_COMPLIANT
  int *exp;
  frexp(NAN, exp);      // NON_COMPLIANT
  frexp(INFINITY, exp); // NON_COMPLIANT
}

void test_pole_errors() {
  atanh(-1.0f); // NON_COMPLIANT
  atanh(1.0f);  // NON_COMPLIANT
  log(0.0f);    // NON_COMPLIANT
  log10(0.0f);  // NON_COMPLIANT
  log2(0.0f);   // NON_COMPLIANT
  log1p(-1.0f); // NON_COMPLIANT
  // logb(x) already covered in domain cases
  pow(0.0f, -1.0f); // NON_COMPLIANT
  lgamma(0.0f);     // NON_COMPLIANT
  lgamma(-1);       // NON_COMPLIANT[FALSE_NEGATIVE]
}