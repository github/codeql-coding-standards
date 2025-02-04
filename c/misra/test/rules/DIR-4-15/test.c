#include "math.h"

float getFloat() { return 1.0; }

// Parameter could be infinity
void f1(float p1) {
  float l1 = 1;
  float l2 = 1.0 / 0;
  float l3 = -l2;

  10 / l1;         // COMPLIANT
  10 / l2;         // NON_COMPLIANT: Underflows to zero
  10 / l3;         // NON_COMPLIANT: Underflow to negative zero
  10 / p1;         // COMPLIANT: Reduce false positives by assuming not infinity
  10 / getFloat(); // COMPLIANT: Reduce false positives by assuming not infinity

  (int)l1;         // COMPLIANT
  (int)l2;         // NON_COMPLIANT
  (int)l3;         // NON_COMPLIANT
  (int)p1;         // COMPLIANT: Reduce false positives by assuming not infinity
  (int)getFloat(); // COMPLIANT: Reduce false positives by assuming not infinity

  // Not NaN:
  float l4 = l1 / l1; // COMPLIANT

  // NaN because of infinity divided by itself:
  float l5 = l2 / l2; // NON_COMPLIANT: Division by infinity not allowed.
  float l6 = l3 / l3; // NON_COMPLIANT: Division by infinity not allowed.

  // NaN because of zero divided by itself:
  float l7 = getFloat() /
             p1; // COMPLIANT: Reduce false positives by assuming not infinity
  float l8 = 0.0 / 0.0;

  (int)l4; // COMPLIANT
  (int)l5; // NON_COMPLIANT: Casting NaN to int
  (int)l6; // NON_COMPLIANT: Casting NaN to int
  (int)l7; // NON_COMPLIANT: Casting NaN to int
  (int)l8; // NON_COMPLIANT: Casting NaN to int

  l4 == 0; // COMPLIANT
  l4 != 0; // COMPLIANT
  l4 <= 0; // COMPLIANT
  l4 < 0;  // COMPLIANT
  l4 >= 0; // COMPLIANT
  l5 == 0; // NON_COMPLIANT: Comparison with NaN always false
  l5 != 0; // NON_COMPLIANT: Comparison with NaN always false
  l5 < 0;  // NON_COMPLIANT: Comparison with NaN always false
  l5 <= 0; // NON_COMPLIANT: Comparison with NaN always false
  l5 > 0;  // NON_COMPLIANT: Comparison with NaN always false
  l5 >= 0; // NON_COMPLIANT: Comparison with NaN always false
  l6 == 0; // NON_COMPLIANT: Comparison with NaN always false
  l7 == 0; // NON_COMPLIANT: Comparison with NaN always false
  l8 == 0; // NON_COMPLIANT: Comparison with NaN always false

  // Guards
  float l9 = 0;
  if (l9 != 0) {
    (int)(l9 / l9); // COMPLIANT: l9 is not zero
  } else {
    (int)(l9 / l9); // NON_COMPLIANT: Guarded to not be NaN
  }

  float l10 = 0;
  if (l10 == 0) {
    (int)(l10 / l10); // NON_COMPLIANT: Casting NaN to integer
  } else {
    (int)(l10 / l10); // COMPLIANT: Guarded to not be NaN
  }

  float l11 = 0;
  l11 == 0 ? (int)(l11 / l11) : 0; // NON_COMPLIANT
  l11 == 0 ? 0 : (int)(l11 / l11); // COMPLIANT
  l11 != 0 ? (int)(l11 / l11) : 0; // COMPLIANT
  l11 != 0 ? 0 : (int)(l11 / l11); // NON_COMPLIANT

  float l12 = 1.0 / 0;
  if (isinf(l12)) {
    (int)l12; // NON_COMPLIANT: Casting Infinity to integer
  } else {
    (int)l12; // COMPLIANT: Guarded not to be Infinity
  }

  if (!isinf(l12)) {
    (int)l12; // COMPLIANT: Guarded not to be Infinity
  } else {
    (int)l12; // NON_COMPLIANT: Casting Infinity to integer
  }

  if (isinf(l12) == 1) {
    (int)l12; // NON_COMPLIANT: Must be +Infinity
  } else {
    (int)l12; // NON_COMPLIANT: May be -Infinity
  }

  if (isfinite(l12)) {
    (int)l12; // COMPLIANT: Guarded not to be Infinity
  } else {
    (int)l12; // NON_COMPLIANT: Casting Infinity to integer
  }

  if (isnormal(l12)) {
    (int)l12; // COMPLIANT: Guarded not to be Infinity
  } else {
    (int)l12; // NON_COMPLIANT: Casting Infinity to integer
  }

  if (isnan(l12)) {
    (int)l12; // COMPLIANT: Guarded not to be Infinity
  } else {
    (int)l12; // NON_COMPLIANT: Casting Infinity to integer
  }

  isinf(l12) ? (int)l12 : 0;    // NON_COMPLIANT: Check on wrong branch
  isinf(l12) ? 0 : (int)l12;    // COMPLIANT: Checked not infinite before use
  isfinite(l12) ? (int)l12 : 0; // COMPLIANT: Checked finite before use
  isfinite(l12) ? 0 : (int)l12; // NON_COMPLIANT: Checked on wrong branch
  isnan(l12) ? (int)l12
             : 0; // COMPLIANT: Checked NaN, therefore not infinite, before use
  isnan(l12) ? 0 : (int)l12; // NON_COMPLIANT: Check on wrong branch

  float l13 = 0.0 / 0;
  if (isinf(l13)) {
    (int)l13; // COMPLIANT: Guarded not to be NaN
  } else {
    (int)l13; // NON_COMPLIANT: Casting NaN to integer
  }

  if (isinf(l13) == 1) {
    (int)l13; // COMPLIANT: Guarded not to be NaN (must be +Infinity)
  } else {
    (int)l13; // NON_COMPLIANT: Casting NaN to integer
  }

  if (isfinite(l13)) {
    (int)l13; // COMPLIANT: Guarded not to be NaN
  } else {
    (int)l13; // NON_COMPLIANT: Casting NaN to integer
  }

  if (isnormal(l13)) {
    (int)l13; // COMPLIANT: Guarded not to be NaN
  } else {
    (int)l13; // NON_COMPLIANT: Casting NaN to integer
  }

  if (isnan(l13)) {
    (int)l13; // NON_COMPLIANT: Casting NaN to integer
  } else {
    (int)l13; // COMPLIANT: Guarded not to be NaN
  }

  isinf(l13) ? (int)l13 : 0;    // COMPLIANT: Checked infinite, therefore not NaN, before use
  isinf(l13) ? 0 : (int)l13;    // COMPLIANT: Check on wrong branch
  isfinite(l13) ? (int)l13 : 0; // COMPLIANT: Checked finite before use
  isfinite(l13) ? 0 : (int)l13; // NON_COMPLIANT: Checked on wrong branch
  isnan(l13) ? (int)l13 : 0; // NON_COMPLIANT: Check on wrong branch
  isnan(l13) ? 0 : (int)l13; // COMPLIANT: Checked not NaN before use
}