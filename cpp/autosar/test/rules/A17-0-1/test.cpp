#undef errno    // NON_COMPLIANT
#define errno 0 // NON_COMPLIANT

#undef assert               // NON_COMPLIANT
#define assert(condition) 0 // NON_COMPLIANT

#undef __LINE__    // NON_COMPLIANT
#define __LINE__ 0 // NON_COMPLIANT

#undef __FILE__    // NON_COMPLIANT
#define __FILE__ 0 // NON_COMPLIANT

#undef __DATE__    // NON_COMPLIANT
#define __DATE__ 0 // NON_COMPLIANT

#undef __TIME__    // NON_COMPLIANT
#define __TIME__ 0 // NON_COMPLIANT

#undef __STDC__    // NON_COMPLIANT
#define __STDC__ 0 // NON_COMPLIANT

#undef __STDC_HOSTED__    // NON_COMPLIANT
#define __STDC_HOSTED__ 0 // NON_COMPLIANT

#undef __cplusplus    // NON_COMPLIANT
#define __cplusplus 0 // NON_COMPLIANT

#undef __STDCPP_THREADS__    // NON_COMPLIANT
#define __STDCPP_THREADS__ 0 // NON_COMPLIANT

#undef __FUNCTION__    // NON_COMPLIANT
#define __FUNCTION__ 0 // NON_COMPLIANT

#undef _Foo  // NON_COMPLIANT
#define _Foo // NON_COMPLIANT

#undef _foo  // NON_COMPLIANT
#define _foo // NON_COMPLIANT

#undef FOO  // COMPLIANT
#define FOO // COMPLIANT

#undef foo  // COMPLIANT
#define foo // COMPLIANT

void test_macros_are_invoked() {
  assert(errno);   // COMPLIANT
  __LINE__;        // COMPLIANT
  __FILE__;        // COMPLIANT
  __DATE__;        // COMPLIANT
  __TIME__;        // COMPLIANT
  __STDC__;        // COMPLIANT
  __STDC_HOSTED__; // COMPLIANT
  __cplusplus;     // COMPLIANT
  __STDC_HOSTED__; // COMPLIANT
  __FUNCTION__;    // COMPLIANT
}