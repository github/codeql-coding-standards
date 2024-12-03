#include "string.h"
#include "threads.h"

mtx_t mutex;
thrd_t thread;
tss_t threadlocal;
cnd_t condition;

extern void use_mutex(mtx_t *m);
extern void use_thread(thrd_t *t);
extern void use_threadlocal(tss_t *t);
extern void use_condition(cnd_t *c);

void valid_usages(void) {
  mtx_init(&mutex, mtx_plain);      // COMPLIANT
  mtx_lock(&mutex);                 // COMPLIANT
  mtx_unlock(&mutex);               // COMPLIANT
  thrd_create(&thread, NULL, NULL); // COMPLIANT
  tss_create(&threadlocal, NULL);   // COMPLIANT
  tss_set(threadlocal, NULL);       // COMPLIANT
  cnd_init(&condition);             // COMPLIANT
  cnd_signal(&condition);           // COMPLIANT
  cnd_wait(&condition, &mutex);     // COMPLIANT

  use_mutex(&mutex);             // COMPLIANT
  use_thread(&thread);           // COMPLIANT
  use_threadlocal(&threadlocal); // COMPLIANT
  use_condition(&condition);     // COMPLIANT
}

extern void copy_mutex(mtx_t m);
extern void copy_thread(thrd_t t);
extern void copy_threadlocal(tss_t t);
extern void copy_condition(cnd_t t);

void invalid_usages(void) {
  mutex = *(mtx_t *)0;       // NON-COMPLIANT
  thread = *(thrd_t *)0;     // NON-COMPLIANT
  threadlocal = *(tss_t *)0; // NON-COMPLIANT
  condition = *(cnd_t *)0;   // NON-COMPLIANT

  int *buf;
  memcpy(&mutex, buf, sizeof(mtx_t));       // NON-COMPLIANT
  memcpy(&thread, buf, sizeof(thrd_t));     // NON-COMPLIANT
  memcpy(&threadlocal, buf, sizeof(tss_t)); // NON-COMPLIANT
  memcpy(&condition, buf, sizeof(cnd_t));   // NON-COMPLIANT

  threadlocal++;    // NON-COMPLIANT
  threadlocal += 1; // NON-COMPLIANT
  threadlocal + 1;  // NON-COMPLIANT

  // mutex == mutex; // NON-COMPLIANT
  // mutex != mutex; // NON-COMPLIANT
  thread == thread;           // NON-COMPLIANT
  thread != thread;           // NON-COMPLIANT
  threadlocal == threadlocal; // NON-COMPLIANT
  threadlocal != threadlocal; // NON-COMPLIANT
  // condition == condition;     // NON-COMPLIANT
  // condition != condition;     // NON-COMPLIANT

  copy_mutex(mutex);             // COMPLIANT
  copy_thread(thread);           // COMPLIANT
  copy_threadlocal(threadlocal); // COMPLIANT
  copy_condition(condition);     // COMPLIANT
}