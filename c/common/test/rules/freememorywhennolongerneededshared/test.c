#include <stdio.h>
#include <stdlib.h>

int f1a(void) {
  void *p = malloc(10); // NON_COMPLIANT
  if (NULL == p) {
    return -1;
  }
  /* ... */
  return 0;
}

int f1b(const void *in) {
  void *p = realloc(in, 10); // NON_COMPLIANT
  if (NULL == p) {
    return -1;
  }
  /* ... */
  return 0;
}

void f1c(const void *in) {
  void *p = realloc(in, 10); // NON_COMPLIANT
  if (NULL == p) {
    return;
  }
  /* ... */
  // pointer out of scope not freed
}

int f2a(void) {
  void *p = malloc(10); // COMPLIANT
  if (NULL == p) {
    return -1;
  }
  /* ... */
  free(p);
  return 0;
}

int f2b(int test) {
  void *p = malloc(10); // NON_COMPLIANT
  if (NULL == p) {
    return -1;
  }
  if (test == 1) {
    free(p);
    return -1;
  }
  // memory not freed on this path
  return 0;
}

// scope prolonged
int f2c(void) {
  void *q;
  {
    void *p = malloc(10); // COMPLIANT
    if (NULL == p) {
      return -1;
    }
    /* ... */
    q = p;
    // p out of scope
  }
  free(q);
  return 0;
}

// interprocedural
int free_helper(void *g) {
  free(g);
  return 0;
}

int f2inter(void) {
  void *p = malloc(10); // COMPLIANT
  if (NULL == p) {
    return -1;
  }
  return free_helper(p);
}