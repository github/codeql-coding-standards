#include <errno.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <wchar.h>
void f1() {
  int n;
  while (scanf("%d", &n) == 1) // NON_COMPLIANT
    printf("%d\n", n);         // NON_COMPLIANT
}

void f2() {
  FILE *fp = fopen("fgetwc.dat", "w");
  wint_t l1;
  int l2 = 0;
  while ((l1 = fgetwc(fp)) != WEOF) { // NON_COMPLIANT
    putwchar(l1);                     // NON_COMPLIANT
  }

  if (ferror(fp)) {
    if (l2 == EILSEQ)
      puts("CodeQL"); // NON_COMPLIANT
    else
      puts("CodeQL"); // NON_COMPLIANT
  } else if (feof(fp))
    puts("CodeQL"); // NON_COMPLIANT
}
