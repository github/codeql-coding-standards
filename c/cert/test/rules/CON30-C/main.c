#include <stdio.h>
#include <stdlib.h>
#include <threads.h>

static tss_t k;

void do_free(void *d) { free(d); }

void maybe_free(void *d) {}

void m1() {
  tss_create(&k, free); // COMPLIANT
  tss_delete(k);
}

void m2() {
  tss_create(&k, do_free); // COMPLIANT
  tss_delete(k);
}

void m3() {
  tss_create(&k, maybe_free); // COMPLIANT
  tss_delete(k);
}

void m1a() {
  tss_create(&k, free); // NON_COMPLIANT - The memory is deallocated, but the
                        // usage pattern is non-standard and may lead to errors.
  free(tss_get(k));
}

void m2a() {
  tss_create(&k,
             do_free); // NON_COMPLIANT - The memory is deallocated, but the
                       // usage pattern is non-standard and may lead to errors.
  free(tss_get(k));
}

void m3a() {
  tss_create(
      &k, maybe_free); // NON_COMPLIANT - The memory is deallocated, but the
                       // usage pattern is non-standard and may lead to errors.
  free(tss_get(k));
}

void m1b() {
  tss_create(&k, NULL); // COMPLIANT
  free(tss_get(k));
}

void m2b() {
  tss_create(&k, NULL); // COMPLIANT
  free(tss_get(k));
}

void m3b() {
  tss_create(&k, NULL); // COMPLIANT
  free(tss_get(k));
}

void m4() {
  tss_create(&k, free); // NON_COMPLIANT
}

void m5() {
  tss_create(&k, do_free); // NON_COMPLIANT
}

void m6() {
  tss_create(&k, maybe_free); // NON_COMPLIANT
}

void m4a() {
  tss_create(&k, NULL); // NON_COMPLIANT
}

void m5a() {
  tss_create(&k, NULL); // NON_COMPLIANT
}

void m6a() {
  tss_create(&k, NULL); // NON_COMPLIANT
}

void m4b() {
  tss_create(&k, NULL); // NON_COMPLIANT
  tss_delete(k);
}

void m5b() {
  tss_create(&k, NULL); // NON_COMPLIANT
  tss_delete(k);
}

void m6b() {
  tss_create(&k, NULL); // NON_COMPLIANT
  tss_delete(k);
}
