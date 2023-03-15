#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define size_of_months (sizeof(months) / sizeof(months[0]))

struct s1 {
  int i;
  char *j;
}

months[] = {{1, "jan"}, {2, "feb"},  {3, "mar"},  {4, "apr"},
            {5, "may"}, {6, "jun"},  {7, "jul"},  {8, "aug"},
            {9, "sep"}, {10, "oct"}, {11, "nov"}, {12, "dec"}};

static int compare(const void *m1, const void *m2) {
  const struct s1 *s11 = m1;
  const struct s1 *s12 = m2;
  return strcmp(s11->j, s12->j);
}

void f1() {
  qsort(months, size_of_months, sizeof(months[0]), compare); // NON_COMPLIANT
  struct s1 key;
  struct s1 *res;

  res = bsearch(&key, months, size_of_months, sizeof(months[0]),
                compare); // NON_COMPLIANT
}
