#include "threads.h"

void f1(void) {
  cnd_t cnd1;
  mtx_t mtx1;
  cnd_wait(&cnd1, &mtx1); // COMPLIANT
  cnd_wait(&cnd1, &mtx1); // COMPLIANT

  cnd_t cnd2;
  mtx_t mtx2;
  cnd_wait(&cnd2, &mtx2); // COMPLIANT
  cnd_wait(&cnd2, &mtx2); // COMPLIANT
}

void f2(void) {
  cnd_t cnd1;
  mtx_t mtx1;
  mtx_t mtx2;
  cnd_wait(&cnd1, &mtx1); // NON-COMPLIANT
  cnd_wait(&cnd1, &mtx2); // NON-COMPLIANT
}

void f3(void) {
  cnd_t cnd1;
  cnd_t cnd2;
  mtx_t mtx1;
  cnd_wait(&cnd1, &mtx1); // COMPLIANT
  cnd_wait(&cnd2, &mtx1); // COMPLIANT
}

void f4(cnd_t *cnd1, mtx_t *mtx1, mtx_t *mtx2) {
  cnd_wait(cnd1, mtx1); // COMPLIANT
  // Compliant, mtx1 and mtx2 may point to the same object
  cnd_wait(cnd1, mtx2); // COMPLIANT
}

cnd_t gcnd1;
mtx_t gmtx1;
mtx_t gmtx2;
void f5(void) {
  cnd_wait(&gcnd1, &gmtx1); // NON-COMPLIANT
}

void f6(void) {
  cnd_wait(&gcnd1, &gmtx2); // NON-COMPLIANT
}