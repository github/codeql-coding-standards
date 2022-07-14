#include <stdlib.h>
#include <threads.h>

typedef struct {
  int sum;
  mtx_t mu;
} B;

typedef struct {
  B *from;
  B *to;
  int amount;
} thread_arg;

int d1(void *arg) { // NON_COMPLIANT
  thread_arg *targ = (thread_arg *)arg;

  B *from = targ->from;
  B *to = targ->to;
  int amount = targ->amount;

  mtx_lock(&from->mu);
  mtx_lock(&to->mu);

  if (from->sum >= amount) {
    from->sum = from->sum - amount;
    to->sum = to->sum + amount;
    return 0;
  }
  return -1;
}

int d2(void *arg) { // NON_COMPLIANT

  thread_arg *targ = (thread_arg *)arg;

  B *from = targ->from;
  B *to = targ->to;
  int amount = targ->amount;

  mtx_lock(&from->mu);
  if (from->sum < amount) {
    return -1;
  }
  mtx_lock(&to->mu);
  from->sum = (from->sum - amount);
  to->sum = (to->sum + amount);

  return 0;
}

int getA() { return 0; }
int getARand() { return rand(); }

int d3(void *arg) { // COMPLIANT

  thread_arg *targ = (thread_arg *)arg;

  B *from = targ->from;
  B *to = targ->to;
  int amount = targ->amount;

  mtx_t *one;
  mtx_t *two;

  int a = getARand();

  // here a may take on multiple different
  // values and thus different values may flow
  // into the locks
  if (a == 9) {
    one = &from->mu;
    two = &to->mu;
  } else {
    one = &to->mu;
    two = &from->mu;
  }

  mtx_lock(one);
  mtx_lock(two);

  from->sum = (from->sum - amount);
  to->sum = (to->sum + amount);

  return 0;
}

int d4(void *arg) { // NON_COMPLIANT

  thread_arg *targ = (thread_arg *)arg;

  B *from = targ->from;
  B *to = targ->to;
  int amount = targ->amount;

  mtx_t *one;
  mtx_t *two;
  int a = getARand();

  // here a may take on multiple different
  // values and thus different values may flow
  // into the locks
  if (a == 9) {
    one = &from->mu;
    two = &to->mu;
  } else {
    one = &to->mu;
    two = &from->mu;
  }

  mtx_lock(&from->mu);
  mtx_lock(&to->mu);

  from->sum = (from->sum - amount);
  to->sum = (to->sum + amount);

  return 0;
}

void f(B *ba1, B *ba2) {
  thrd_t t1, t2;

  // unsafe - but used for testing
  thread_arg a1 = {.from = ba1, .to = ba2, .amount = 100};

  thread_arg a2 = {.from = ba2, .to = ba1, .amount = 100};

  thrd_create(&t1, d1, &a1);
  thrd_create(&t2, d1, &a2);
}

void f2(B *ba1, B *ba2) {
  thrd_t t1, t2;

  // unsafe - but used for testing
  thread_arg a1 = {.from = ba1, .to = ba2, .amount = 100};

  thread_arg a2 = {.from = ba2, .to = ba1, .amount = 100};

  thrd_create(&t1, d2, &a1);
  thrd_create(&t2, d2, &a2);
}

void f3(B *ba1, B *ba2) {
  thrd_t t1, t2;

  // unsafe - but used for testing
  thread_arg a1 = {.from = ba1, .to = ba2, .amount = 100};

  thread_arg a2 = {.from = ba2, .to = ba1, .amount = 100};

  thrd_create(&t1, d3, &a1);
  thrd_create(&t2, d3, &a2);
}

void f4(B *ba1, B *ba2) {
  thrd_t t1, t2;

  // unsafe - but used for testing
  thread_arg a1 = {.from = ba1, .to = ba2, .amount = 100};

  thread_arg a2 = {.from = ba2, .to = ba1, .amount = 100};

  thrd_create(&t1, d4, &a1);
  thrd_create(&t2, d4, &a2);
}
