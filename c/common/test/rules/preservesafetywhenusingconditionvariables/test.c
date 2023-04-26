#include <threads.h>

cnd_t condition;
void t1(void *a) {
  cnd_signal(&condition); // NON_COMPLIANT
}

void t2(void *a) {
  cnd_broadcast(&condition); // COMPLIANT
}

void t3(void *a) {
  cnd_signal(&condition); // COMPLIANT (not a thread)
}

void f1() {
  thrd_t threads[5];

  mtx_t mxl;

  mtx_init(&mxl, mtx_plain); // COMPLIANT

  for (size_t i = 0; i < 1; i++) {
    thrd_create(&threads[i], t1, &mxl);
  }

  for (size_t i = 0; i < 1; i++) {
    thrd_join(threads[i], 0);
  }

  mtx_destroy(&mxl);
}

void f2() {
  thrd_t threads[5];

  mtx_t mxl;

  mtx_init(&mxl, mtx_plain); // COMPLIANT

  for (size_t i = 0; i < 1; i++) {
    thrd_create(&threads[i], t2, &mxl);
  }

  for (size_t i = 0; i < 1; i++) {
    thrd_join(threads[i], 0);
  }

  mtx_destroy(&mxl);
}
