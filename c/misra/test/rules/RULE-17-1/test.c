#include <stdarg.h> //NON_COMPLIANT

#define MAXARGS 31

void f1(va_list p1) // NON_COMPLIANT
{
  double l1;
  l1 = va_arg(p1, double); // NON_COMPLIANT
}

void f2(const char *p1, const char *args, ...) {
  va_list l1; // NON_COMPLIANT
  char *array[MAXARGS + 1];
  int argno = 0;

  va_start(l1, args); // NON_COMPLIANT
  while (args != 0 && argno < MAXARGS) {
    array[argno++] = args;
    args = va_arg(l1, const char *); // NON_COMPLIANT
  }
  array[argno] = (char *)0;
  va_end(l1); // NON_COMPLIANT
}

void f3(int p1, ...) {
  int l1 = 0;
  va_list l2;       // NON_COMPLIANT
  va_list l3;       // NON_COMPLIANT
  va_start(l2, p1); // NON_COMLIANT
  va_copy(l3, l2);  // NON_COMPLIANT
  va_end(l3);       // NON_COMPLIANT
}
