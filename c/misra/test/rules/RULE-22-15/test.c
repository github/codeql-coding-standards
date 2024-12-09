#include "threads.h"

mtx_t g1;
tss_t g2;
cnd_t g3;

int t1_use_none(void *p) { return 0; }

int t2_use_all(void *p) {
  mtx_lock(&g1);
  tss_get(&g2);
  cnd_wait(&g3, &g1);
}

int t3_dispose_all(void *p) {
  mtx_destroy(&g1);
  tss_delete(&g2);
  cnd_destroy(&g3);
}

int t4_use_then_dispose(void *p) {
  mtx_lock(&g1);
  tss_get(&g2);
  cnd_wait(&g3, &g1);

  mtx_destroy(&g1);
  tss_delete(&g2);
  cnd_destroy(&g3);
}

void f1() {
  thrd_t t;
  thrd_create(&t, t1_use_none, NULL);
  mtx_destroy(&g1);
  tss_delete(&g2);
  cnd_destroy(&g3);
}

void f2() {
  thrd_t t;
  thrd_create(&t, t2_use_all, NULL);
  mtx_destroy(&g1); // NON-COMPLIANT
  tss_delete(&g2);  // NON-COMPLIANT
  cnd_destroy(&g3); // NON-COMPLIANT
}

void f3() {
  thrd_t t;
  thrd_create(&t, t2_use_all, NULL); // COMPLIANT
}

void f4() {
  thrd_t t;
  thrd_create(&t, t2_use_all, NULL); // COMPLIANT
  thrd_join(&t, NULL);
  mtx_destroy(&g1); // COMPLIANT
  tss_delete(&g2);  // COMPLIANT
  cnd_destroy(&g3); // COMPLIANT
}

void f5() {
  thrd_t t1;
  thrd_t t2;
  thrd_create(&t1, t2_use_all, NULL);     // COMPLIANT
  thrd_create(&t2, t3_dispose_all, NULL); // NON-COMPLIANT
}

void f6() {
  thrd_t t1;
  thrd_t t2;
  thrd_create(&t1, t3_dispose_all, NULL); // NON-COMPLIANT
  thrd_create(&t2, t2_use_all, NULL);     // COMPLIANT
}

void f7() {
  thrd_t t1;
  thrd_t t2;
  thrd_create(&t1, t2_use_all, NULL); // COMPLIANT
  thrd_join(&t1, NULL);
  thrd_create(&t2, t3_dispose_all, NULL); // COMPLIANT
}

void f8() {
  thrd_t t;
  thrd_create(&t, t4_use_then_dispose, NULL); // COMPLIANT
}

void f9() {
  thrd_t t;
  thrd_create(&t, t3_dispose_all, NULL); // NON-COMPLIANT
  mtx_lock(&g1);
  tss_get(&g2);
  cnd_wait(&g3, &g1);
}

void f10() {
  thrd_t t;
  mtx_lock(&g1);
  tss_get(&g2);
  cnd_wait(&g3, &g1);
  thrd_create(&t, t3_dispose_all, NULL); // COMPLIANT
}

void f11() {
  thrd_t t;
  thrd_create(&t, t1_use_none, NULL);
  mtx_lock(&g1);
  tss_get(&g2);
  cnd_wait(&g3, &g1);
  mtx_destroy(&g1); // COMPLIANT
  tss_delete(&g2);  // COMPLIANT
  cnd_destroy(&g3); // COMPLIANT
}