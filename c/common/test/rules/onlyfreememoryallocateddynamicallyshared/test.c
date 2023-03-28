#include <stdio.h>
#include <stdlib.h>

int g_i = 0;
void *g_p = &g_i;

void test_global(void) {
  free(g_p); // NON_COMPLIANT
  g_p = &g_i;
  free(g_p); // NON_COMPLIANT
  g_p = malloc(10);
  free(g_p); // COMPLIANT[FALSE_POSITIVE] - but could be written to in different
             // scope
}

void test_global_b(void) { free(g_p); } // NON_COMPLIANT

void free_nested(void *ptr) { free(ptr); } // NON_COMPLIANT - some paths

void get_allocated_memory(void **p) { *p = malloc(10); }

void test_local(void) {
  int i;
  int j;
  void *p = &i;
  free(p); // NON_COMPLIANT
  p = &j;
  free_nested(p); // NON_COMPLIANT - reported on line 18
  p = malloc(10);
  free(p); // COMPLIANT
  p = malloc(10);
  free_nested(p); // COMPLIANT
  get_allocated_memory(&p);
  free(p); // COMPLIANT
}

struct S {
  int i;
  void *p;
};

void test_local_field_nested(struct S *s) { free(s->p); } // COMPLIANT

void test_local_field(void) {
  struct S s;
  s.p = &s.i;
  free(s.p); // NON_COMPLIANT[FALSE_NEGATIVE]
  s.p = malloc(10);
  free(s.p); // COMPLIANT
  s.p = malloc(10);
  test_local_field_nested(&s);
}