#include <stddef.h>
#include <string.h>

unsigned long copy_to_user(void *to, const void *from, unsigned long n);

typedef struct _point {
  int x;
  int y;
} point;

void callee1(point *p) {
  p->y = 1;
  copy_to_user(0, p, sizeof(point)); // COMPLIANT
}

void caller1() {
  point p;
  p.x = 1;
  callee1(&p);
}

void callee2(point *p) {
  memset(p, 0, sizeof(point));
  copy_to_user(0, p, sizeof(point)); // COMPLIANT
}

void caller2() {
  point p;
  callee2(&p);
}

void assign_x(point *p, int value) { p->x = value; }

void zero_y(point *p) { memset(&p->y, 0, sizeof(p->y)); }

void call_to_overwrite_x() {
  point p;
  assign_x(&p, 1);
  copy_to_user(0, &p, sizeof p); // NON_COMPLIANT
}

void call_to_overwrite_both() {
  point p;
  assign_x(&p, 1);
  zero_y(&p);
  copy_to_user(0, &p, sizeof p); // COMPLIANT
}

void zero_y_and_loop(point *p) {
  int i;
  memset(&p->y, 0, sizeof(p->y));
  for (i = 0; i < 10; i++) {
    p->y++;
  }
}

void call_zero_y_and_loop() {
  point p;
  zero_y_and_loop(&p);
  assign_x(&p, 1);
  copy_to_user(0, &p, sizeof p); // COMPLIANT
}

int zero_y_or_fail(point *p) {
  if (p->x < 0) {
    return 0;
  }
  p->y = 0;
  return 1;
}

void call_zero_y_or_fail(int i) {
  point p;
  p.x = i;
  if (!zero_y_or_fail(&p)) {
    return;
  }
  copy_to_user(0, &p, sizeof p); // COMPLIANT
}

int zero_y_proxy(point *p) {
  if (p->x) {
    zero_y(p);
  } else {
    zero_y(p);
  }
}

void call_zero_y_proxy() {
  point p;
  zero_y_proxy(&p);
  assign_x(&p, 1);
  copy_to_user(0, &p, sizeof p); // COMPLIANT
}

void overwrite_after_leak(point *p) {
  copy_to_user(0, p, sizeof(*p)); // NON_COMPLIANT

  p->x = 0;
  p->y = 0;
}

void call_overwrite_after_leak(void) {
  point p;
  overwrite_after_leak(&p);
  copy_to_user(0, &p, sizeof p); // COMPLIANT
}