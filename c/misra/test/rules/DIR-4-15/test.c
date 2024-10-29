#include "math.h"

extern void use_float(float x);
extern float get_float(void);

// Parameter could be infinity
void f1(float x) {
  if (isfinite(x)) {
    use_float(x); // COMPLIANT
  } else {
    use_float(x); // NON-COMPLIANT
  }
  use_float(x); // NON-COMPLIANT
  float y = 20.0;
  use_float(y); // COMPLIANT
}

void f2() {
  float x = 1 / 0;
  float y = 1 / 0;

  sizeof(y);
  float z = y + 2;
  if (isfinite(y)) {
    return;
  }
}