#include <locale.h>
#include <string.h>

void f1(void) {
  char *s1 = setlocale(LC_ALL, 0); // NON_COMPLIANT
  struct lconv *lc = localeconv(); // NON_COMPLIANT
  s1[1] = '0';
  lc->currency_symbol = "$";
}

void f2helper(char *s) {}
void f2(void) {
  char s[128];
  strcpy(s, setlocale(LC_ALL, 0));      // COMPLIANT
  f2helper(setlocale(LC_ALL, 0));       // NON_COMPLIANT
  const struct lconv *c = localeconv(); // COMPLIANT
}

void f3(void) {
  const struct lconv *c = localeconv(); // COMPLIANT
  c->grouping[0] = '0';                 // NON_COMPLIANT
}