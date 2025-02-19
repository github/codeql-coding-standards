#include "stdlib.h"
#include "threads.h"

void use_local_mtxs(int x, int y) {
  tss_t l1;
  tss_get(&l1); // NON-COMPLIANT
  tss_create(&l1, NULL);
  tss_get(&l1); // COMPLIANT

  tss_t *l4 = malloc(sizeof(tss_t));
  tss_get(l4); // NON-COMPLIANT
  tss_create(l4, NULL);
  tss_get(l4); // COMPLIANT
}

void root1_calls_use_local_mtxs() {
  // Since a function exists which calls use_local_mtxs(), that function is not
  // a root function. The query should still report unused locals in this case.
  use_local_mtxs(1, 2);
}

tss_t g1;

void root2_uses_global_tss_t() {
  tss_get(&g1); // NON-COMPLIANT
}

void from_root3_use_global_tss_t() {
  tss_get(&g1); // COMPLIANT
}

void root3_initializes_and_uses_global_tss_t() {
  tss_create(&g1, NULL);
  from_root3_use_global_tss_t();
}

void from_root4_use_global_tss_t(void *arg) {
  tss_get(&g1); // NON-COMPLIANT
}

void root4_call_thread_without_initialization() {
  thrd_t t;
  thrd_create(&t, &from_root4_use_global_tss_t, NULL);
}

void from_root5_use_global_tss_t(void *arg) {
  tss_get(&g1); // COMPLIANT
}

void root5_thread_with_initialization() {
  tss_create(&g1, NULL);
  thrd_t t;
  thrd_create(&t, &from_root5_use_global_tss_t, NULL);
}

mtx_t g5;
void from_root6_init_and_use_thread_local() {
  tss_get(&g5); // NON-COMPLIANT

  // Violates recommendation, tss_t initialized within a thread.
  tss_create(&g5, NULL); // NON-COMPLIANT

  // Valid if we except the above initialization.
  tss_get(&g5); // COMPLIANT
}

void root6_spawn_thread_uninitialized_thread_local() {
  thrd_t t;
  thrd_create(&t, &from_root6_init_and_use_thread_local, NULL);
}