#include "threads.h"

mtx_t rec;
mtx_t nonrec;
mtx_t both;
mtx_t unknown;

struct {
  mtx_t m;
} s;

mtx_t arr[2];

int t1(void *arg) {
  mtx_lock(&rec); // COMPLIANT
  mtx_lock(&rec); // COMPLIANT

  mtx_lock(&nonrec); // COMPLIANT
  mtx_lock(&nonrec); // NON-COMPLIANT

  mtx_lock(&s.m); // COMPLIANT
  mtx_lock(&s.m); // NON-COMPLIANT
}

void f1() {
  mtx_init(&rec, mtx_plain | mtx_recursive);
  mtx_init(&nonrec, mtx_plain);
  mtx_init(&both, mtx_plain);
  mtx_init(&both, mtx_plain | mtx_recursive);
  // Do not initialize `unknown`.
  mtx_init(&s.m, mtx_plain);
  mtx_init(&arr[0], mtx_plain);
  mtx_init(&arr[1], mtx_plain);

  thrd_t t;
  thrd_create(t, t1, NULL);
}

mtx_t *p;

// Results for the audit query:
void t2(void *arg) {
  mtx_lock(&arr[0]);
  mtx_lock(&arr[(int)arg]); // NON-COMPLIANT
}

void t3(void *arg) {
  mtx_lock(arg);
  mtx_lock(p); // NON-COMPLIANT
}

void t4() {
  mtx_lock(&both);
  mtx_lock(&both); // NON-COMPLIANT
}

void t5() {
  mtx_lock(&unknown);
  mtx_lock(&unknown); // NON-COMPLIANT
}

void t6() {
  // Cannot be locks of the same mutex:
  mtx_lock(&nonrec);
  mtx_lock(&unknown); // COMPLIANT
}

void t7() {
  mtx_lock(p);
  // Definitely a recursive mutex:
  mtx_lock(&rec); // COMPLIANT
}

void t8() {
  mtx_lock(p);
  mtx_lock(&nonrec); // NON-COMPLIANT
}

void t9() {
  mtx_lock(&nonrec);
  mtx_lock(p); // NON-COMPLIANT
}

void f2() {
  thrd_t t;
  thrd_create(t, t2, NULL);
}

void f3() {
  thrd_t t;
  thrd_create(t, t3, &rec);
}

void f4() {
  thrd_t t;
  thrd_create(t, t4, NULL);
}

void f5() {
  thrd_t t;
  thrd_create(t, t5, NULL);
}

void f6() {
  thrd_t t;
  thrd_create(t, t6, NULL);
}

void f7() {
  thrd_t t;
  thrd_create(t, t7, NULL);
}

void f8() {
  thrd_t t;
  thrd_create(t, t8, NULL);
}

void f9() {
  thrd_t t;
  thrd_create(t, t9, NULL);
}