#ifndef _RESERVED_MACRO
#define _RESERVED_MACRO // Not reported by this rule
#endif                  /* _RESERVED_MACRO */

#ifndef _also_reserved_MACRO
#define _also_reserved_MACRO // Not reported by this rule
#endif                       /* _not_reserved_MACRO */

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

extern int
    errno; // NON_COMPLIANT - errno is explicitly reserved for external linkage

void output(int a, int b, int c);

#define DEBUG(...)                                                             \
  output(__VA_ARGS__) // COMPLIANT - using not declaring `__VA_ARGS__`

void test() {
  DEBUG(1, 2, 3);
  __FUNCTION__;        // COMPLIANT - use, not declaration of `__FUNCTION__`
  __PRETTY_FUNCTION__; // COMPLIANT - use, not declaration of
                       // `__PRETTY_FUNCTION__`
}
#include <tgmath.h>
void test2(int log); // NON_COMPLIANT - tgmath.h defines log as a reserved macro

/* Test _[A-Z] */

int _Test_global;      // NON_COMPLIANT - _ followed by capital is reserved
void _Test_func(       // NON_COMPLIANT - _ followed by capital is reserved
    int _Test_param) { // NON_COMPLIANT - _ followed by capital is reserved
  int _Test_local;     // NON_COMPLIANT - _ followed by capital is reserved
  struct _Test_struct_local { // NON_COMPLIANT - _ followed by capital is
                              // reserved
    int _Test_member; // NON_COMPLIANT - _ followed by capital is reserved
  };
}
struct _Test_struct { // NON_COMPLIANT - _ followed by capital is reserved
  int _Test_member;   // NON_COMPLIANT - _ followed by capital is reserved
};
#define _TEST_MACRO x // Not reported by this rule

/* Test __ */

int __test_double_global;             // NON_COMPLIANT - double _ is reserved
void __test_double_func(              // NON_COMPLIANT - double _ is reserved
    int __test_double_param) {        // NON_COMPLIANT - double _ is reserved
  int __test_double_local;            // NON_COMPLIANT - double _ is reserved
  struct __test_double_struct_local { // NON_COMPLIANT - double _ is reserved
    int __test_double_member;         // NON_COMPLIANT - double _ is reserved
  };
}
struct __test_double_struct { // NON_COMPLIANT - double _ is reserved
  int __test_double_member;   // NON_COMPLIANT - double _ is reserved
};
#define __TEST_MACRO x // Not reported by this rule

/*
 * Test _, but not followed by underscore or upper case, which is reserved in
 * file scope and ordinary/tag name spaces
 */

int _test_lower_global; // NON_COMPLIANT - _ is reserved in ordinary name space
void _test_lower_func(  // NON_COMPLIANT - _ is reserved as a function name in
                        // ordinary name space
    int _test_lower_param) { // COMPLIANT - _ is not reserved in the block name
                             // space
  int _test;            // COMPLIANT - _ is not reserved in the block name space
  struct _test_struct { // COMPLIANT - _ is not reserved in the block name space
    int _test; // COMPLIANT -  _ is not reserved in the block name space
  };
}
struct _test_struct { // NON_COMPLIANT - _ is reserved in the tag name space
  int _test;          // COMPLIANT - _ is not reserved in the member name space
};
#define _test_macro x // Not reported by this rule

/* Identify names reserved as a macro when the relevant header is included. */
int FE_INEXACT;    // NON_COMPLIANT - FE_INEXACT is reserved as a macro name
void FE_DIVBYZERO( // NON_COMPLIANT - FE_DIVBYZERO is reserved as a macro name
    int FE_INEXACT) { // NON_COMPLIANT - FE_INEXACT is reserved as a macro name
  int FE_INVALID;     // NON_COMPLIANT - FE_INEXACT is reserved as a macro name
  struct FE_INEXACT { // NON_COMPLIANT - FE_INEXACT is reserved as a macro name
    int FE_INEXACT;   // NON_COMPLIANT - FE_INEXACT is reserved as a macro name
  };
}
struct FE_INEXACT { // NON_COMPLIANT - FE_INEXACT is reserved as a macro name
  int FE_INEXACT;   // NON_COMPLIANT - FE_INEXACT is reserved as a macro name
};
#define FE_INEXACT x // Not reported by this rule

// We include the header after the declarations to avoid the inbuilt macros
// expanding in the declarations above. The rule is not, however, sensitive
// to location, so we should still report in this case.
#include <fenv.h>

/* Functions and objects with external linkage */

int exit; // NON_COMPLIANT - reserved for external linkage, even though header
          // was not included
void free() { // NON_COMPLIANT - reserved for external linkage, even though
              // header was not included
}
static int rand; // COMPLIANT - only reserved for external linkage or if random
                 // was included
static int srand() { // COMPLIANT - only reserved for external linkage or if
                     // random was included
}

#include <string.h>
#define strlen 0 // Not reported by this rule

// The examples below are non compliant, because those symbols are reserved in
// file scope when string.h is included.  However, the compiler/edg rejects the
// declaration cases, so we cannot test them.

// static int strlen;
// static void *memcpy(void *s1, const void *s2, size_t n) {}

#include <time.h>
#define tm_sec 0 // Not reported by this rule

// The examples below are non compliant, because those symbols are reserved in
// file scope when time.h is included.  However, the compiler/edg rejects the
// declaration cases, so we cannot test them.

// struct tm {
//   int tm_sec;
//   int tm_min;
//   int tm_hour;
//   int tm_mday;
//   int tm_mon;
//   int tm_year;
//   int tm_wday;
//   int tm_yday;
//   int tm_isdst;
//   long __tm_gmtoff;
//   const char *__tm_zone;
// };

// Examples below are compliant because threads.h is not included

#define tss_set 0   // Not reported by this rule
static int tss_get; // COMPLIANT - threads.h not included, not external linkage
static void
tss_delete(        // COMPLIANT - threads.h not included, not external linkage
    int tss_create // COMPLIANT - threads.h not included
) {
  int thrd_detach;   // COMPLIANT - threads.h not included
  struct thrd_join { // COMPLIANT - threads.h not included
    int thrd_equal;  // COMPLIANT - threads.h not included
  };
}
struct thrd_yield { // COMPLIANT - threads.h not included
  int thrd_exit;    // COMPLIANT - threads.h not included
};

#include <sys/select.h>
void test_macro() {
  fd_set test_set;
  FD_ZERO(&test_set); // COMPLIANT - macro expands to variables with `__`
                      // prefixes, but should be excluded
}
