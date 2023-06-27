#include <setjmp.h>

int test_jmps() {
  jmp_buf env;
  int val;

  val = setjmp(env);
  if (val) {
    return (val);
  }

  longjmp(env, 101);

  longjmp(env, 102);

  val = setjmp(env);

  return 0;
}