#include "stdlib.h"
#include "threads.h"

void use_local_mtxs(int x, int y) {
  mtx_t l1;
  mtx_lock(&l1); // NON-COMPLIANT
  mtx_init(&l1, mtx_plain);
  mtx_lock(&l1); // COMPLIANT

  struct {
    mtx_t m;
  } l2;
  mtx_lock(&l2.m); // NON-COMPLIANT
  mtx_init(&l2.m, mtx_plain);
  mtx_lock(&l2.m); // COMPLIANT

  mtx_t l3[10];
  mtx_lock(&l3[y]); // NON-COMPLIANT
  mtx_init(&l3[x], mtx_plain);
  mtx_lock(&l3[y]); // COMPLIANT

  mtx_t *l4 = malloc(sizeof(mtx_t));
  mtx_lock(l4); // NON-COMPLIANT
  mtx_init(l4, mtx_plain);
  mtx_lock(l4); // COMPLIANT
}

void root1_calls_use_local_mtxs() {
  // Since a function exists which calls use_local_mtxs(), that function is not
  // a root function. The query should still report unused locals in this case.
  use_local_mtxs(1, 2);
}

mtx_t g1;
struct {
  mtx_t m1;
} g2;
mtx_t *g3;

void root2_uses_global_mutexes() {
  mtx_lock(&g1);    // NON-COMPLIANT
  mtx_lock(&g2.m1); // NON-COMPLIANT
  mtx_lock(g3);     // NON-COMPLIANT
}

void from_root3_use_global_mutexes() {
  mtx_lock(&g1);    // COMPLIANT
  mtx_lock(&g2.m1); // COMPLIANT
  mtx_lock(g3);     // COMPLIANT
}

void root3_initializes_and_uses_global_mutexes() {
  // Init global mutex with an allocated storage duration object. The existence
  // of this malloc() is not checked by the query, but if its exists, the object
  // and its uses should be trackable as a nice bonus.
  g3 = malloc(sizeof(mtx_t));
  mtx_init(&g1, mtx_plain);
  mtx_init(&g2.m1, mtx_plain);
  mtx_init(g3, mtx_plain);
  from_root3_use_global_mutexes();
}

void from_root4_use_global_mutex(void *arg) {
  mtx_lock(&g1); // NON-COMPLIANT
}

void root4_call_thread_without_initialization() {
  thrd_t t;
  thrd_create(&t, &from_root4_use_global_mutex, NULL);
}

void from_root5_use_global_mutex(void *arg) {
  mtx_lock(&g1); // COMPLIANT
}

void root5_thread_with_initialization() {
  mtx_init(&g1, mtx_plain);
  thrd_t t;
  thrd_create(&t, &from_root5_use_global_mutex, NULL);
}

// Set up two functions such that a calls b and b calls a. This means there is
// no root function, but we should still report unused locals.
void island2_call_island1();

void island1_use_uninitialized_mutex() {
  mtx_t l1;
  mtx_lock(&l1); // NON-COMPLIANT

  // Globals are hard to detect
  mtx_lock(&g1); // NON-COMPLIANT[False negative]

  island2_call_island1();
}

void island2_call_island1() { island1_use_uninitialized_mutex(); }

_Thread_local mtx_t g5;
void root6_use_thread_local() {
  mtx_lock(&g5); // NON-COMPLIANT
  mtx_init(&g5, mtx_plain);
  mtx_lock(&g5); // COMPLIANT
}

void from_root7_use_thread_local() {
  // Invalid, thread local g5 hasn't been initialized in this thread.
  mtx_lock(&g5); // NON-COMPLIANT

  // Violates recommendation, mutexes initialized within a thread.
  mtx_init(&g5, mtx_plain); // NON-COMPLIANT

  // Valid if we except the above initialization.
  mtx_lock(&g5); // COMPLIANT
}

void root7_spawn_thread_uninitialized_thread_local() {
  thrd_t t;
  thrd_create(&t, &from_root7_use_thread_local, NULL);
}

void root8_uninitialized_cnd() {
  cnd_t c;
  mtx_t m;
  cnd_wait(&c, &m); // NON-COMPLIANT

  mtx_init(&m, mtx_plain);
  cnd_wait(&c, &m); // NON-COMPLIANT

  cnd_init(&c);
  cnd_wait(&c, &m); // COMPLIANT
}

void invalid_mtx_init_types() {
  mtx_t m;
  mtx_init(&m, mtx_plain);                 // COMPLIANT
  mtx_init(&m, mtx_plain | mtx_recursive); // COMPLIANT
  mtx_init(&m, mtx_timed);                 // COMPLIANT
  mtx_init(&m, mtx_timed | mtx_recursive); // COMPLIANT

  mtx_init(&m, mtx_recursive);             // NON-COMPLIANT
  mtx_init(&m, mtx_plain | mtx_timed);     // NON-COMPLIANT
  mtx_init(&m, mtx_plain | mtx_plain);     // NON-COMPLIANT
  mtx_init(&m, mtx_plain & mtx_recursive); // NON-COMPLIANT
  mtx_init(&m, mtx_plain * mtx_recursive); // NON-COMPLIANT
  mtx_init(&m, -1);                        // NON-COMPLIANT
}

void function_pointer_uses_global_mutexes() {
  // If the function has been used as a function pointer, we don't attempt to
  // analyze this.
  mtx_lock(&g1);    // COMPLIANT
  mtx_lock(&g2.m1); // COMPLIANT
  mtx_lock(g3);     // COMPLIANT
}

void take_function_pointer() {
  void (*f)(void) = function_pointer_uses_global_mutexes;
}