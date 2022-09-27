#include <stdio.h>
#include <stdlib.h>
#include <threads.h>

static tss_t k;

void t1(void *data) {}
void t2(void *data) { free(tss_get(k)); }
void t3(void *data) {
  void *p = tss_get(k);
  free(p);
}

void do_free(void *d) { free(d); }
void maybe_free(void *d) {}

void m1() {
  thrd_t id;
  tss_create(&k, free); // COMPLIANT
  thrd_create(&id, t1, NULL);
  thrd_join(id, NULL);
  tss_delete(k);
}

void m1a() {
  thrd_t id;
  tss_create(&k, free); // NON_COMPLIANT - Doesn't wait for thread to cleanup
                        // resources; if tss_delete is called prior to thread
                        // termination the destructor won't be called.
  thrd_create(&id, t1, NULL);
  tss_delete(k);
}

void m1b() {
  tss_create(&k, free); // COMPLIANT - No threads created.
  tss_delete(k);
}

void m2() {
  thrd_t id;
  tss_create(&k, do_free); // COMPLIANT
  thrd_create(&id, t1, NULL);
  thrd_join(id, NULL);
  tss_delete(k);
}

void m2a() {
  thrd_t id;
  tss_create(&k, do_free); // NON_COMPLIANT - Doesn't wait for thread to cleanup
                           // resources; if tss_delete is called prior to thread
                           // termination the destructor won't be called.
  thrd_create(&id, t1, NULL);
  tss_delete(k);
}

void m2b() {
  tss_create(&k, do_free); // COMPLIANT - No threads created.
  tss_delete(k);
}

void m3() {
  thrd_t id;
  tss_create(&k, maybe_free); // COMPLIANT
  thrd_create(&id, t1, NULL);
  thrd_join(id, NULL);
  tss_delete(k);
}

void m3a() {
  thrd_t id;
  tss_create(&k,
             maybe_free); // NON_COMPLIANT - Doesn't wait for thread to cleanup
                          // resources; if tss_delete is called prior to thread
                          // termination the destructor won't be called.
  thrd_create(&id, t1, NULL);
  tss_delete(k);
}

void m3b() {
  tss_create(&k, maybe_free); // COMPLIANT - No threads created.
  tss_delete(k);
}

void m4() {
  thrd_t id;

  tss_create(&k, free); // NON_COMPLIANT - The memory is deallocated, but the
                        // usage pattern is non-standard and may lead to errors.
  thrd_create(&id, t2, NULL);
  thrd_join(id, NULL);
  tss_delete(k);
}

void m5() {
  tss_create(&k, NULL); // NON_COMPLIANT - `tss_delete` should be called.
}

void m5a() {
  thrd_t id;

  tss_create(&k, NULL); // COMPLIANT
  thrd_create(&id, t2, NULL);
  thrd_join(id, NULL);
  tss_delete(k);
}

void m5aa() {
  thrd_t id;

  tss_create(&k, NULL); // COMPLIANT
  thrd_create(&id, t3, NULL);
  thrd_join(id, NULL);
  tss_delete(k);
}

void m5b() {
  thrd_t id;

  tss_create(&k, NULL); // COMPLIANT - Cleanup can happen before OR after
                        // `tss_delete` is called; so there is no need to wait.
  thrd_create(&id, t2, NULL);
  tss_delete(k);
}

void m5bb() {
  thrd_t id;

  tss_create(&k, NULL); // COMPLIANT - Cleanup can happen before OR after
                        // `tss_delete` is called; so there is no need to wait.
  thrd_create(&id, t3, NULL);
  tss_delete(k);
}

void m6() {
  tss_create(&k, free); // NON_COMPLIANT
}

void m7() {
  tss_create(&k, do_free); // NON_COMPLIANT
}

void m8() {
  tss_create(&k, maybe_free); // NON_COMPLIANT
}

void m9() {
  tss_create(&k, NULL); // NON_COMPLIANT
}

void m10() {
  tss_create(&k, NULL); // NON_COMPLIANT
}

void m11() {
  tss_create(&k, NULL); // NON_COMPLIANT
}
