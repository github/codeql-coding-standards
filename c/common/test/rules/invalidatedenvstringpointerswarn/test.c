#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct test_struct {
  char *tmpvar_field;
};

char *tmpvar_global;

void f1(void) {
  tmpvar_global = getenv("TMP"); // NON_COMPLIANT

  struct test_struct s;
  s.tmpvar_field = getenv("TEMP"); // NON_COMPLIANT

  char *tmpvar_local = getenv("TEMP"); // COMPLIANT
}
