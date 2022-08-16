#include <stddef.h>
#include <threads.h>

int t3(void *data) {
  mtx_t *mxl = (mtx_t *)data;
  mtx_lock(mxl);
  mtx_unlock(mxl);
  return 0;
}

int t4(void *data) {
  mtx_t *mxl = (mtx_t *)data;
  mtx_lock(mxl);
  mtx_unlock(mxl);
  return 0;
}

// case 3 - correctly waiting for a well-behaved thread, with a local mutex.
int f3() {
  thrd_t threads[5];

  mtx_t mxl;

  mtx_init(&mxl, mtx_plain); // COMPLIANT

  for (size_t i = 0; i < 1; i++) {
    thrd_create(&threads[i], t3, &mxl);
  }

  for (size_t i = 0; i < 1; i++) {
    thrd_join(threads[i], 0);
  }

  mtx_destroy(&mxl);
  return 0;
}

// case 4 - incorrectly waiting for a well behaved thread, with a local mutex.
int f4() {
  thrd_t threads[5];
  mtx_t mxl;

  mtx_init(&mxl, mtx_plain); // NON_COMPLIANT

  for (size_t i = 0; i < 1; i++) {
    thrd_create(&threads[i], t3, &mxl);
  }

  mtx_destroy(&mxl);
  return 0;
}

// case 5 - incorrectly waiting with a stack local variable.
int f5() {
  thrd_t threads[5];
  mtx_t mxl;

  mtx_init(&mxl, mtx_plain); // NON_COMPLIANT

  for (size_t i = 0; i < 1; i++) {
    thrd_create(&threads[i], t4, &mxl);
  }

  return 0;
}

// case 6 - correctly waiting with a stack local variable.
int f6() {
  thrd_t threads[5];
  mtx_t mxl;

  mtx_init(&mxl, mtx_plain); // COMPLIANT

  for (size_t i = 0; i < 1; i++) {
    thrd_create(&threads[i], t4, &mxl);
  }

  for (size_t i = 0; i < 1; i++) {
    thrd_join(threads[i], 0);
  }

  return 0;
}
