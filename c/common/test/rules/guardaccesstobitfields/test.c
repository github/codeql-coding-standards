#include <threads.h>

struct BitFieldStruct {
  unsigned int flag1 : 2;
  unsigned int flag2 : 2;
};

struct BitFieldStruct flags;

int f1(void *arg) {
  flags.flag1 = 1; // NON_COMPLIANT
  return 0;
}

int f2(void *arg) {
  flags.flag2 = 2; // NON_COMPLIANT
  return 0;
}

struct MutexStruct {
  struct BitFieldStruct s;
  mtx_t mutex;
};

struct MutexStruct flags2;

int f3(void *arg) {
  if (thrd_success != mtx_lock(&flags2.mutex)) {
    return 0;
  }
  flags2.s.flag1 = 1; // COMPLIANT
  return 0;
}

int f4(void *arg) {
  if (thrd_success != mtx_lock(&flags2.mutex)) {
    return 0;
  }
  flags2.s.flag2 = 2; // COMPLIANT
  mtx_unlock(&flags2.mutex);
  return 0;
}

int f5(void *arg) {
  mtx_lock(&flags2.mutex);
  mtx_unlock(&flags2.mutex);
  flags2.s.flag2 = 2; // NON_COMPLIANT

  return 0;
}

int f6(void *arg) {
  mtx_lock(&flags2.mutex);
  mtx_unlock(&flags2.mutex);
  mtx_lock(&flags2.mutex);
  flags2.s.flag2 = 2; // COMPLIANT

  return 0;
}

void m() {

  thrd_create(NULL, (thrd_start_t)f1, NULL);
  thrd_create(NULL, (thrd_start_t)f2, NULL);
  thrd_create(NULL, (thrd_start_t)f3, NULL);
  thrd_create(NULL, (thrd_start_t)f4, NULL);
  thrd_create(NULL, (thrd_start_t)f5, NULL);
  thrd_create(NULL, (thrd_start_t)f6, NULL);
}