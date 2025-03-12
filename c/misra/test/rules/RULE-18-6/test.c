#include <threads.h>

typedef struct {
  int *p;
  int m
} s;

_Thread_local int t1;
_Thread_local int *t2;
_Thread_local s t3;
int g1;
int *g2;
s g3;

void f1() {
  // Regular object accesses
  t1 = t1;   // COMPLIANT
  t1 = *t2;  // COMPLIANT
  t1 = g1;   // COMPLIANT
  t1 = *g2;  // COMPLIANT
  g1 = t1;   // COMPLIANT
  g1 = *t2;  // COMPLIANT
  g1 = g1;   // COMPLIANT
  g1 = *g2;  // COMPLIANT
  t2 = &t1;  // COMPLIANT
  t2 = t2;   // COMPLIANT
  t2 = &g1;  // COMPLIANT
  t2 = g2;   // COMPLIANT
  g2 = &t1;  // NON-COMPLIANT
  g2 = t2;   // COMPLIANT
  g2 = &g1;  // COMPLIANT
  g2 = g2;   // COMPLIANT
  *t2 = t1;  // COMPLIANT
  *t2 = *t2; // COMPLIANT
  *t2 = g1;  // COMPLIANT
  *t2 = *g2; // COMPLIANT
  *g2 = t1;  // COMPLIANT
  *g2 = *t2; // COMPLIANT
  *g2 = g1;  // COMPLIANT
  *g2 = *g2; // COMPLIANT

  // Subobject accesses
  t3.m = t3.m;   // COMPLIANT
  t3.m = *t3.p;  // COMPLIANT
  t3.m = g3.m;   // COMPLIANT
  t3.m = *g3.p;  // COMPLIANT
  g3.m = t3.m;   // COMPLIANT
  g3.m = *t3.p;  // COMPLIANT
  g3.m = g3.m;   // COMPLIANT
  g3.m = *g3.p;  // COMPLIANT
  t3.p = &t3.m;  // COMPLIANT
  t3.p = t3.p;   // COMPLIANT
  t3.p = &g3.m;  // COMPLIANT
  t3.p = g3.p;   // COMPLIANT
  g3.p = &t3.m;  // NON-COMPLIANT
  g3.p = t3.p;   // COMPLIANT
  g3.p = &g3.m;  // COMPLIANT
  g3.p = g3.p;   // COMPLIANT
  *t3.p = t3.m;  // COMPLIANT
  *t3.p = *t3.p; // COMPLIANT
  *t3.p = g3.m;  // COMPLIANT
  *t3.p = *g3.p; // COMPLIANT
  *g3.p = t3.m;  // COMPLIANT
  *g3.p = *t3.p; // COMPLIANT
  *g3.p = g3.m;  // COMPLIANT
  *g3.p = *g3.p; // COMPLIANT

  // Storing values in locals (automatic storage duration)
  int l1;
  int *l2;
  s l3;

  l1 = l1;       // COMPLIANT
  l1 = *l2;      // COMPLIANT
  l1 = l3.m;     // COMPLIANT
  l1 = *l3.p;    // COMPLIANT
  l1 = t1;       // COMPLIANT
  l1 = *t2;      // COMPLIANT
  l1 = t3.m;     // COMPLIANT
  l1 = *t3.p;    // COMPLIANT
  l1 = g1;       // COMPLIANT
  l1 = *g2;      // COMPLIANT
  l1 = g3.m;     // COMPLIANT
  l1 = *g3.p;    // COMPLIANT
  l2 = &l1;      // COMPLIANT
  l2 = l2;       // COMPLIANT
  l2 = &l3.m;    // COMPLIANT
  l2 = l3.p;     // COMPLIANT
  l2 = &t1;      // COMPLIANT
  l2 = t2;       // COMPLIANT
  l2 = &t3.m;    // COMPLIANT
  l2 = t3.p;     // COMPLIANT
  l2 = &g1;      // COMPLIANT
  l2 = g2;       // COMPLIANT
  l2 = &g3.m;    // COMPLIANT
  l2 = g3.p;     // COMPLIANT
  *l2 = l1;      // COMPLIANT
  *l2 = *l2;     // COMPLIANT
  *l2 = l3.m;    // COMPLIANT
  *l2 = *l3.p;   // COMPLIANT
  *l2 = t1;      // COMPLIANT
  *l2 = *t2;     // COMPLIANT
  *l2 = t3.m;    // COMPLIANT
  *l2 = *t3.p;   // COMPLIANT
  *l2 = g1;      // COMPLIANT
  *l2 = *g2;     // COMPLIANT
  *l2 = g3.m;    // COMPLIANT
  *l2 = *g3.p;   // COMPLIANT
  l3.m = l1;     // COMPLIANT
  l3.m = *l2;    // COMPLIANT
  l3.m = l3.m;   // COMPLIANT
  l3.m = *l3.p;  // COMPLIANT
  l3.m = t1;     // COMPLIANT
  l3.m = *t2;    // COMPLIANT
  l3.m = t3.m;   // COMPLIANT
  l3.m = *t3.p;  // COMPLIANT
  l3.m = g1;     // COMPLIANT
  l3.m = *g2;    // COMPLIANT
  l3.m = g3.m;   // COMPLIANT
  l3.m = *g3.p;  // COMPLIANT
  l3.p = &l1;    // COMPLIANT
  l3.p = l2;     // COMPLIANT
  l3.p = &l3.m;  // COMPLIANT
  l3.p = l3.p;   // COMPLIANT
  l3.p = &t1;    // COMPLIANT
  l3.p = t2;     // COMPLIANT
  l3.p = &t3.m;  // COMPLIANT
  l3.p = t3.p;   // COMPLIANT
  l3.p = &g1;    // COMPLIANT
  l3.p = g2;     // COMPLIANT
  l3.p = &g3.m;  // COMPLIANT
  l3.p = g3.p;   // COMPLIANT
  *l3.p = l1;    // COMPLIANT
  *l3.p = *l2;   // COMPLIANT
  *l3.p = l3.m;  // COMPLIANT
  *l3.p = *l3.p; // COMPLIANT
  *l3.p = t1;    // COMPLIANT
  *l3.p = *t2;   // COMPLIANT
  *l3.p = t3.m;  // COMPLIANT
  *l3.p = *t3.p; // COMPLIANT
  *l3.p = g1;    // COMPLIANT
  *l3.p = *g2;   // COMPLIANT
  *l3.p = g3.m;  // COMPLIANT
  *l3.p = *g3.p; // COMPLIANT

  // Storing local values in globals is covered by the shared query.
}

tss_t tss1;
void f2() {
  g1 = *(int *)tss_get(&tss1);       // COMPLIANT
  g2 = tss_get(&tss1);               // NON-COMPLIANT
  *g2 = *(int *)tss_get(&tss1);      // COMPLIANT
  g3.m = *(int *)tss_get(&tss1);     // COMPLIANT
  g3.p = tss_get(&tss1);             // NON-COMPLIANT
  *g3.p = *(int *)tss_get(&tss1);    // COMPLIANT
  g1 = ((s *)tss_get(&tss1))->m;     // COMPLIANT
  g1 = *((s *)tss_get(&tss1))->p;    // COMPLIANT
  g2 = &((s *)tss_get(&tss1))->m;    // NON-COMPLIANT[false negative]
  g2 = *((s *)tss_get(&tss1))->p;    // COMPLIANT
  *g2 = ((s *)tss_get(&tss1))->m;    // COMPLIANT
  *g2 = *((s *)tss_get(&tss1))->p;   // COMPLIANT
  g3.m = ((s *)tss_get(&tss1))->m;   // COMPLIANT
  g3.m = *((s *)tss_get(&tss1))->p;  // COMPLIANT
  g3.p = &((s *)tss_get(&tss1))->m;  // NON-COMPLIANT[false negative]
  g3.p = *((s *)tss_get(&tss1))->p;  // COMPLIANT
  *g3.p = ((s *)tss_get(&tss1))->m;  // COMPLIANT
  *g3.p = *((s *)tss_get(&tss1))->p; // COMPLIANT
}