#include <setjmp.h>
#include <stdlib.h>

void exit1(void) { // COMPLIANT
  return;
}

void exit1bad(void) { // NON_COMPLIANT
  extern int condition;
  if (condition) {
    exit(0);
  }
  return;
}

int f1(void) {
  if (atexit(exit1) != 0) {
    /* Handle error */
  }
  if (atexit(exit1bad) != 0) {
    /* Handle error */
  }
  /* ... Program code ... */
  return 0;
}

int f1safe(void) {
  if (atexit(exit1) != 0) {
    /* Handle error */
  }
  if (at_quick_exit(exit1) != 0) {
    /* Handle error */
  }
  /* ... Program code ... */
  return 0;
}

jmp_buf env;
int val;

void exit2(void) { // NON_COMPLIANT
  longjmp(env, 1);
}

int f2(void) {
  if (at_quick_exit(exit2) != 0) {
    /* Handle error */
  }
  if (setjmp(env) == 0) {
  } else {
    return 0;
  }
}

int f2safe(void) {
  if (atexit(exit1) != 0) {
    /* Handle error */
  }
  return 0;
}

void exit3_helper(void) { longjmp(env, 1); }

void exit3(void) { // NON_COMPLIANT
  exit3_helper();
}

int f3(void) {
  if (atexit(exit3) != 0) {
    /* Handle error */
  }
  return 0;
}
