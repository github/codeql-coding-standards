#include <stddef.h>
#include <threads.h>

/// Note that since this is a C test case, mutexes
/// are not created/valid until `mtx_init` is called.
mtx_t mx1;
mtx_t mx2;

int t1(void *data) {
  mtx_lock(&mx1);
  mtx_unlock(&mx1);
  return 0;
}

int t2(void *data) {
  mtx_lock(&mx2);
  mtx_unlock(&mx2);
  return 0;
}

int t3(void *data) {
  mtx_t *mxl = (mtx_t *)data;
  mtx_lock(mxl);
  mtx_unlock(mxl);
  return 0;
}

// case 1 - correctly waiting for a well-behaved thread
int f1() {
  thrd_t threads[5];

  mtx_init(&mx1, mtx_plain); // COMPLIANT

  for (size_t i = 0; i < 1; i++) {
    thrd_create(&threads[i], t1, NULL);
  }
  for (size_t i = 0; i < 1; i++) {
    thrd_join(threads[i], 0);
  }

  mtx_destroy(&mx1);
  return 0;
}

// case 2 - incorrectly waiting for a well behaved thread.
int f2() {
  thrd_t threads[5];

  mtx_init(&mx2, mtx_plain); // NON_COMPLIANT

  for (size_t i = 0; i < 1; i++) {
    thrd_create(&threads[i], t2, NULL);
  }

  mtx_destroy(&mx2);
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
