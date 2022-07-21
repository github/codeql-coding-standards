#include <stddef.h>
#include <threads.h>

static mtx_t lk;
static cnd_t cnd;

void f1() {
  mtx_lock(&lk);

  if (1) {
    cnd_wait(&cnd, &lk); // NON_COMPLIANT
  }
}

void f2() {
  mtx_lock(&lk);
  int i = 2;
  while (i > 0) {
    cnd_wait(&cnd, &lk); // COMPLIANT
    i--;
  }
}

void f3() {
  mtx_lock(&lk);
  int i = 2;
  do {
    cnd_wait(&cnd, &lk); // COMPLIANT
    i--;
  } while (i > 0);
}

void f4() {
  mtx_lock(&lk);

  for (;;) {
    cnd_wait(&cnd, &lk); // COMPLIANT
  }
}

void f5() {
  mtx_lock(&lk);

  int i = 2;
  while (i > 0) {
    i--;
  }

  cnd_wait(&cnd, &lk); // NON_COMPLIANT
}

void f6() {
  mtx_lock(&lk);

  for (int i = 0; i < 10; i++) {
  }
  int i = 0;
  if (i > 0) {
    cnd_wait(&cnd, &lk); // NON_COMPLIANT
    i--;
  }
}
