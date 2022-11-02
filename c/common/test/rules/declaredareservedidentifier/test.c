#ifndef _RESERVED_MACRO
#define _RESERVED_MACRO // NON_COMPLIANT
#endif                  /* _RESERVED_MACRO */

#ifndef _not_reserved_MACRO
#define _not_reserved_MACRO // COMPLIANT
#endif                      /* _not_reserved_MACRO */

static const int INT_LIMIT_MAX = 12000; // COMPLIANT future library directions

struct _s {         // NON_COMPLIANT
  struct _s *_next; // COMPLIANT not file scope
};

void _f() { // NON_COMPLIANT
  int _p;   // COMPLIANT not file scope
}

void *malloc(int bytes) { // NON_COMPLIANT
  void *ptr;
  return ptr;
}

extern int errno; // NON_COMPLIANT