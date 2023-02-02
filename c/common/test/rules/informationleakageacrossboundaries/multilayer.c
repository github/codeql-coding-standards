#include <stddef.h>
#include <string.h>

unsigned long copy_to_user(void *to, const void *from, unsigned long n);

typedef struct {
  int x;
} intx;

typedef struct {
  intx a;
  intx b;
} intxab;

void forget_y() {
  intxab s;
  s.a.x = 1;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT (y)
}

void set_both() {
  intxab s;
  s.a.x = 1;
  memset(&s.b, 0, sizeof s.b);
  copy_to_user(0, &s, sizeof s); // COMPLIANT
}

void set_none() {
  intxab s;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT (both)
}

void set_none_intx() {
  intx s;
  copy_to_user(0, &s, sizeof s); // NON_COMPLIANT (x)
}