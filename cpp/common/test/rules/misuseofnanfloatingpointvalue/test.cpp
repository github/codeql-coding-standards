#include <cmath>

float getFloat() { return 1.0; }

// Parameter could be infinity
void f1(float p1) {
  float l1 = 1;
  float l2 = 1.0 / 0;
  float l3 = -l2;

  10 / l1;         // COMPLIANT
  10 / l2;         // COMPLIANT: Underflows to zero
  10 / l3;         // COMPLIANT: Underflow to negative zero
  10 / p1;         // COMPLIANT: Reduce false positives by assuming not infinity
  10 / getFloat(); // COMPLIANT: Reduce false positives by assuming not infinity

  (int)l1;         // COMPLIANT
  (int)l2;         // COMPLIANT
  (int)l3;         // COMPLIANT
  (int)p1;         // COMPLIANT: Reduce false positives by assuming not infinity
  (int)getFloat(); // COMPLIANT: Reduce false positives by assuming not infinity

  // Not NaN:
  float l4 = l1 / l1; // COMPLIANT

  // NaN because of infinity divided by itself:
  float l5 = l2 / l2; // COMPLIANT: Division by infinity not allowed.
  float l6 = l3 / l3; // COMPLIANT: Division by infinity not allowed.

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
    (int)(l9 / l9); // NON_COMPLIANT: Casting NaN to integer
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
  if (std::isinf(l12)) {
    (int)l12; // COMPLIANT: Casting Infinity to integer
  } else {
    (int)l12; // COMPLIANT: Guarded not to be Infinity
  }

  if (!std::isinf(l12)) {
    (int)l12; // COMPLIANT: Guarded not to be Infinity
  } else {
    (int)l12; // COMPLIANT: Casting Infinity to integer
  }

  if (std::isinf(l12) == 1) {
    (int)l12; // COMPLIANT: Must be +Infinity
  } else {
    (int)l12; // COMPLIANT: May be -Infinity
  }

  if (std::isfinite(l12)) {
    (int)l12; // COMPLIANT: Guarded not to be Infinity
  } else {
    (int)l12; // COMPLIANT: Casting Infinity to integer
  }

  if (std::isnormal(l12)) {
    (int)l12; // COMPLIANT: Guarded not to be Infinity
  } else {
    (int)l12; // COMPLIANT: Casting Infinity to integer
  }

  if (std::isnan(l12)) {
    (int)l12; // COMPLIANT: Guarded not to be Infinity
  } else {
    (int)l12; // COMPLIANT: Casting Infinity to integer
  }

  std::isinf(l12) ? (int)l12 : 0; // COMPLIANT: Check on wrong branch
  std::isinf(l12) ? 0 : (int)l12; // COMPLIANT: Checked not infinite before use
  std::isfinite(l12) ? (int)l12 : 0; // COMPLIANT: Checked finite before use
  std::isfinite(l12) ? 0 : (int)l12; // COMPLIANT: Checked on wrong branch
  std::isnan(l12)
      ? (int)l12
      : 0; // COMPLIANT: Checked NaN, therefore not infinite, before use
  std::isnan(l12) ? 0 : (int)l12; // COMPLIANT: Check on wrong branch

  float l13 = 0.0 / 0;
  if (std::isinf(l13)) {
    (int)l13; // COMPLIANT: Guarded not to be NaN
  } else {
    (int)l13; // NON_COMPLIANT: Casting NaN to integer
  }

  if (std::isinf(l13) == 1) {
    (int)l13; // COMPLIANT: Guarded not to be NaN (must be +Infinity)
  } else {
    (int)l13; // NON_COMPLIANT: Casting NaN to integer
  }

  if (std::isfinite(l13)) {
    (int)l13; // COMPLIANT: Guarded not to be NaN
  } else {
    (int)l13; // NON_COMPLIANT: Casting NaN to integer
  }

  if (std::isnormal(l13)) {
    (int)l13; // COMPLIANT: Guarded not to be NaN
  } else {
    (int)l13; // NON_COMPLIANT: Casting NaN to integer
  }

  if (std::isnan(l13)) {
    (int)l13; // NON_COMPLIANT: Casting NaN to integer
  } else {
    (int)l13; // COMPLIANT: Guarded not to be NaN
  }

  std::isinf(l13)
      ? (int)l13
      : 0; // COMPLIANT: Checked infinite, therefore not NaN, before use
  std::isinf(l13) ? 0 : (int)l13;    // NON_COMPLIANT: Check on wrong branch
  std::isfinite(l13) ? (int)l13 : 0; // COMPLIANT: Checked finite before use
  std::isfinite(l13) ? 0 : (int)l13; // NON_COMPLIANT: Checked on wrong branch
  std::isnan(l13) ? (int)l13 : 0;    // NON_COMPLIANT: Check on wrong branch
  std::isnan(l13) ? 0 : (int)l13;    // COMPLIANT: Checked not NaN before use

  (int)std::pow(2, p1);           // COMPLIANT: likely to be Infinity
  (int)std::pow(2, std::sin(p1)); // COMPLIANT: not likely to be Infinity
  (int)(1 /
        std::sin(p1)); // COMPLIANT: possible infinity from zero in denominator
  (int)(1 / std::log(p1)); // COMPLIANT: not possibly zero in denominator
  (int)std::pow(p1, p1);   // NON_COMPLIANT: NaN if p1 is zero
  if (p1 != 0) {
    (int)std::pow(p1, p1); // COMPLIANT: p1 is not zero
  }

  (int)std::acos(p1);           // NON_COMPLIANT: NaN if p1 is not within -1..1
  (int)std::acos(std::cos(p1)); // COMPLIANT: cos(p1) is within -1..1
}

void castToInt(float p) { (int)p; }

void checkBeforeCastToInt(float p) {
  if (std::isfinite(p)) {
    castToInt(p);
  }
}

void castToIntToFloatToInt(float p) {
  // This should be reported as a violation, but not downstream from here.
  castToInt((int)p);
}

void addOneThenCastToInt(float p) { castToInt(p + 1); }
void addInfThenCastToInt(float p) { castToInt(p + 1.0 / 0.0); }
void addNaNThenCastToInt(float p) { castToInt(p + 0.0 / 0.0); }

void f2() {
  castToInt(1.0 / 0.0); // COMPLIANT: Infinity flows to denominator in division
  castToInt(0.0 / 0.0); // COMPLIANT: NaN flows to denominator in division
  checkBeforeCastToInt(1.0 / 0.0);  // COMPLIANT
  checkBeforeCastToInt(0.0 / 0.0);  // COMPLIANT
  addOneThenCastToInt(1.0 / 0.0);   // COMPLIANT
  addOneThenCastToInt(0.0 / 0.0);   // NON_COMPLIANT
  castToIntToFloatToInt(1.0 / 0.0); // COMPLIANT
  castToIntToFloatToInt(0.0 / 0.0); // NON_COMPLIANT

  // Check that during flow analysis, we only report the true root cause:
  float rootInf = 1.0 / 0.0;
  float rootNaN = 0.0 / 0.0;
  float middleInf = rootInf + 1;
  float middleNaN = rootNaN + 1;
  castToInt(middleInf);           // COMPLIANT
  castToInt(middleNaN);           // NON_COMPLIANT
  addInfThenCastToInt(middleInf); // COMPLIANT
  addNaNThenCastToInt(middleNaN); // NON_COMPLIANT
}