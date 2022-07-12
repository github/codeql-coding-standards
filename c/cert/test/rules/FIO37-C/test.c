#include <stdbool.h>
#include <stdio.h>
#include <string.h>

char buf[1024];

void f1() {
  if (fgets(buf, sizeof(buf), stdin) == NULL) {
    /*null*/
    return;
  }
  /*notnull*/
  buf[strlen(buf) - 1] = '\0'; // NON_COMPLIANT
  return;
}

void f2() {
  char *p;
  if (fgets(buf, sizeof(buf), stdin)) {
    /*notnull*/
    p = strchr(buf, '\n');
    if (p) {
      *p = '\0'; //  COMPLIANT
    }
  }
  return;
}

static inline bool strends(const char *str, const char *postfix) {
  if (strlen(str) < strlen(postfix))
    return false;

  return strcmp(str + strlen(str) - strlen(postfix), postfix) == 0;
}
void f3() {
  if (fgets(buf, sizeof(buf), stdin)) {
    /*notnull*/
    if (strends(buf, "\n")) {
      buf[strlen(buf) - 1] = '\0'; // COMPLIANT
    }
  }
  return;
}

void f4() {
  char *p;
  if (fgets(buf, sizeof(buf), stdin) == NULL) {
    return;
  }
  p = strchr(buf, '\n');
  if (p) {
    *p = '\0'; //  COMPLIANT
  }

  return;
}
