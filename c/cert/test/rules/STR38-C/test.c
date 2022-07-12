#include <stddef.h>

// defined in <string.h> and <wchar.h> but we get absolute
// paths using the current alert so they are defined here.
// to prevent absolute paths from being generated.
char *strncpy(char *__restrict, const char *__restrict, size_t);
wchar_t *wcsncpy(wchar_t *__restrict, const wchar_t *__restrict, size_t);

void f1() {
  wchar_t w1[] = L"codeql";
  wchar_t w2[] = L"codeql";
  char n1[] = "codeql";
  char n2[] = "codeql";

  strncpy(w2, w1, 1); // NON_COMPLIANT (2x)
  strncpy(w2, n1, 1); // NON_COMPLIANT (1x)
  strncpy(n2, n1, 1); // COMPLIANT
}

void f2() {
  wchar_t w1[] = L"codeql";
  wchar_t w2[] = L"codeql";
  char n1[] = "codeql";
  char n2[] = "codeql";

  wcsncpy(n2, n1, 1); // NON_COMPLIANT (2x)
  wcsncpy(w2, n1, 1); // NON_COMPLIANT (1x)
  wcsncpy(w2, w1, 1); // COMPLIANT
}

void f3(wchar_t *w1, wchar_t *w2, char *n1, char *n2) {
  strncpy(w2, w1, 1); // NON_COMPLIANT (2x)
  strncpy(w2, n1, 1); // NON_COMPLIANT (1x)
  strncpy(n2, n1, 1); // COMPLIANT

  wcsncpy(n2, n1, 1); // NON_COMPLIANT (2x)
  wcsncpy(w2, n1, 1); // NON_COMPLIANT (1x)
  wcsncpy(w2, w1, 1); // COMPLIANT
}