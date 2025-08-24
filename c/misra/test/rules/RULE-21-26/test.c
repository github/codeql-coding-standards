#include "threads.h"

mtx_t g1;
mtx_t g2;
mtx_t g3;
mtx_t g4;

struct timespec ts = {0, 0};

void doTimeLock(mtx_t *m) { mtx_timedlock(m, &ts); }

int main(int argc, char *argv[]) {
  mtx_init(&g1, mtx_plain);
  mtx_timedlock(&g1, &ts); // NON-COMPLIANT
  doTimeLock(&g1);         // NON-COMPLIANT

  mtx_init(&g2, mtx_plain | mtx_recursive);
  mtx_timedlock(&g2, &ts); // NON-COMPLIANT
  doTimeLock(&g2);         // NON-COMPLIANT

  mtx_init(&g3, mtx_timed);
  mtx_timedlock(&g3, &ts); // COMPLIANT
  doTimeLock(&g3);         // COMPLIANT

  mtx_init(&g4, mtx_timed | mtx_recursive);
  mtx_timedlock(&g4, &ts); // COMPLIANT
  doTimeLock(&g4);         // COMPLIANT

  mtx_t l1;
  mtx_init(&l1, mtx_plain);
  mtx_timedlock(&l1, &ts); // NON-COMPLIANT
  doTimeLock(&l1);         // NON-COMPLIANT

  mtx_t l2;
  mtx_init(&l2, mtx_timed);
  mtx_timedlock(&l2, &ts); // COMPLIANT
  doTimeLock(&l2);         // COMPLIANT

  struct s {
    mtx_t m;
  } l3;
  mtx_init(&l3.m, mtx_plain);
  mtx_timedlock(&l3.m, &ts); // NON-COMPLIANT
  doTimeLock(&l3.m);         // NON-COMPLIANT
}