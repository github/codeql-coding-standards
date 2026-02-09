#include "threads.h"

mtx_t g1;
struct {
  mtx_t m1;
} g2;

cnd_t cnd;

void f1(int p) {
  mtx_t l1;
  struct {
    mtx_t m1;
  } l2;

  mtx_lock(&l1);
  cnd_wait(&cnd, &l1); // COMPLIANT
  mtx_unlock(&l1);     // COMPLIANT
  cnd_wait(&cnd, &l1); // NON-COMPLIANT
  mtx_unlock(&l1);     // NON-COMPLIANT

  mtx_lock(&l2.m1);
  cnd_wait(&cnd, &l2.m1); // COMPLIANT
  mtx_unlock(&l2.m1);     // COMPLIANT
  cnd_wait(&cnd, &l2.m1); // NON-COMPLIANT
  mtx_unlock(&l2.m1);     // NON-COMPLIANT

  mtx_lock(&g1);
  cnd_wait(&cnd, &g1); // COMPLIANT
  mtx_unlock(&g1);     // COMPLIANT
  cnd_wait(&cnd, &g1); // NON-COMPLIANT
  mtx_unlock(&g1);     // NON-COMPLIANT

  mtx_lock(&g2.m1);
  cnd_wait(&cnd, &g2.m1); // COMPLIANT
  mtx_unlock(&g2.m1);     // COMPLIANT
  cnd_wait(&cnd, &g2.m1); // NON-COMPLIANT
  mtx_unlock(&g2.m1);     // NON-COMPLIANT

  // We should report when a mutex is unlocked in the wrong block:
  if (p) {
    mtx_lock(&l1);
    mtx_lock(&l2.m1);
    mtx_lock(&g1);
    mtx_lock(&g2.m1);
  }
  cnd_wait(&cnd, &l1);    // NON-COMPLIANT
  cnd_wait(&cnd, &l2.m1); // NON-COMPLIANT
  cnd_wait(&cnd, &g1);    // NON-COMPLIANT
  cnd_wait(&cnd, &g2.m1); // NON-COMPLIANT
  mtx_unlock(&l1);        // NON-COMPLIANT
  mtx_unlock(&l2.m1);     // NON-COMPLIANT
  mtx_unlock(&g1);        // NON-COMPLIANT
  mtx_unlock(&g2.m1);     // NON-COMPLIANT

  // The above requires dominance analysis. Check dominator sets don't cause
  // false positives:
  if (p) {
    mtx_lock(&l1);
  } else {
    mtx_lock(&l1);
  }
  mtx_unlock(&l1); // COMPLIANT

  // Invalid but satisfies the rule:
  mtx_lock(&l1);
  if (p) {
    mtx_unlock(&l1); // COMPLIANT
  }
}