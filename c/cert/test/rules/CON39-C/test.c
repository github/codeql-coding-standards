#include <stddef.h>
#include <threads.h>

void detach(thrd_t t) { thrd_detach(t); }

int t1(void *p) {
  thrd_detach(thrd_current());
  return 0;
}

int t2(void *p) { return 0; }

int t3(void *p) {
  thrd_detach(thrd_current());
  thrd_detach(thrd_current());
  return 0;
}

int t4(void *p) {
  detach(thrd_current());
  return 0;
}

void p1() {
  thrd_t t;
  thrd_create(&t, t1, NULL); // NON_COMPLIANT
  thrd_join(t, 0);
}

void p2() {
  thrd_t t;
  thrd_create(&t, t3, NULL); // NON_COMPLIANT - detach called multiple times.
}

void p3(int a, int b) {
  thrd_t t;
  thrd_create(&t, t2, NULL); // NON_COMPLIANT - Join in parent 2x
  thrd_join(t, 0);

  if (a > b) {
    thrd_join(t, 0);
  }
}

void p4() {
  thrd_t t;
  thrd_create(&t, t1, NULL); // COMPLIANT
}

void p5() {
  thrd_t t;
  thrd_create(&t, t2, NULL); // COMPLIANT
  thrd_join(t, 0);
}

void p6() {
  thrd_t t;
  thrd_create(&t, t2, NULL); // NON_COMPLIANT

  thrd_detach(t);
  thrd_join(t, 0);
}

void p7() {
  thrd_t t;
  thrd_create(&t, t2, NULL); // NON_COMPLIANT
  thrd_join(t, 0);
  thrd_detach(t);
}

void p8() {
  thrd_t t;
  thrd_create(&t, t2, NULL); // NON_COMPLIANT

  thrd_detach(t);
  thrd_detach(t);
}

void p9() {
  thrd_t t;
  thrd_create(&t, t2, NULL); // COMPLIANT
  detach(t);
}

void p10() {
  thrd_t t;
  thrd_create(&t, t2, NULL); // NON_COMPLIANT
  thrd_detach(t);
  detach(t);
}

void p11() {
  thrd_t t;
  thrd_create(&t, t4, NULL); // NON_COMPLIANT
  thrd_detach(t);
}
