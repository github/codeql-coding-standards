#include <stdio.h>
#include <stdlib.h>
#include <threads.h>

static tss_t k;

void t1(void *v) {
  int *value = (int *)v;
  int a = *value + 1;
}

void t2(void *v) {
  int *value =
      tss_get(k); // NON_COMPLIANT (AUDIT) - A threaded function without a
                  // `tss_set` should be considered suspicious.
  int a = *value + 1;
}

void m1() {
  thrd_t id;
  int value;

  thrd_create(&id, t1, &value); // NON_COMPLIANT
}

void m2() {
  thrd_t id;
  int *value = (int *)malloc(sizeof(int));

  thrd_create(&id, t1, value); // COMPLIANT - free is never called
}

void m3() {
  thrd_t id;
  int *value = (int *)malloc(sizeof(int));

  thrd_create(&id, t1,
              value); // COMPLIANT - free is called without synchronization,
                      // however this is beyond the scope of this query.
  free(value);
}

void m4() {
  thrd_t id;
  int *value = (int *)realloc(NULL, sizeof(int));

  thrd_create(&id, t1, value); // COMPLIANT

  thrd_join(id, NULL);

  free(value);
}

void m5() {
  thrd_t id;
  int *value = (int *)malloc(sizeof(int));

  tss_create(&k, free);
  tss_set(k, value);

  void *p = tss_get(k);

  thrd_create(&id, t1, p); // COMPLIANT
}

void m5a() {
  thrd_t id;
  int *value = (int *)malloc(sizeof(int));

  tss_set(k, value);

  void *p = tss_get(k);

  thrd_create(&id, t1, p); // NON_COMPLIANT - k not initialized.
}

void m6() {
  thrd_t id;
  int *value = (int *)malloc(sizeof(int));

  tss_create(&k, free);

  void *p = tss_get(k);

  thrd_create(&id, t1, p); // NON_COMPLIANT -- get without set
}

void m6a() {
  thrd_t id;
  int *value = (int *)malloc(sizeof(int));

  void *p = tss_get(k);

  thrd_create(&id, t1, p); // NON_COMPLIANT -- get without set
}

void m7(void *v) {
  int *value =
      tss_get(k); // COMPLIANT (AUDIT) - A non-threaded function without a
                  // `tss_set` should not be considered suspicious.
  int a = *value + 1;
}

void m8() {
  thrd_t id;
  int *value = (int *)malloc(sizeof(int));
  thrd_create(&id, t2,
              value); // COMPLIANT - note that t2 (which is now a threaded
                      // function) is NON_COMPLIANT in an audit query.
}

void m9() {
  thrd_t id;
  static int value = 100;
  thrd_create(&id, t1, &value); // COMPLIANT - compliant for static values.
}