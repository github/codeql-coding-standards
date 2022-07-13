#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <wchar.h>

void f1(void) {
  int c;

  do {
    c = getchar();    // COMPLIANT
  } while (c != EOF); // NON_PORTABLE
}

void f2a(void) {
  int c;

  do {
    c = getchar();  // COMPLIANT
  } while (c != EOF // NON_PORTABLE
           || (!feof(stdin) && !ferror(stdin)));
}

void f2b(void) {
  int c;

  do {
    c = getchar(); // NON_COMPLIANT
  } while (!feof(stdin));
}

void f2c(void) {
  int c;

  do {
    c = getchar(); // NON_COMPLIANT
  } while (!ferror(stdin));
}

void f2d(void) {
  int c;

  do {
    c = getchar(); // NON_COMPLIANT
    // wrong file: read from `stdin` but checking `stdout`
  } while ((!feof(stdout) && !ferror(stdout)));
}

void f2e(void) {
  int c;

  do {
    c = getchar(); // COMPLIANT
  } while ((!feof(stdin) && !ferror(stdin)));
}

enum { BUFFER_SIZE = 32 };

void f3(void) {
  wchar_t buf[BUFFER_SIZE];
  wchar_t wc;
  size_t i = 0;

  while ((wc = getwc(stdin)) != L'\n' && wc != WEOF) { // NON_COMPLIANT
    if (i < (BUFFER_SIZE - 1)) {
      buf[i++] = wc;
    }
  }
  buf[i] = L'\0';
}

void f4(void) {
  wchar_t buf[BUFFER_SIZE];
  wint_t wc;
  size_t i = 0;

  while ((wc = getwc(stdin)) != L'\n' // COMPLIANT
         && wc != WEOF) {             // PORTABLE
    if (i < BUFFER_SIZE - 1) {
      buf[i++] = wc;
    }
  }

  if (feof(stdin) || ferror(stdin)) {
    buf[i] = L'\0';
  } else {
    /* Received a wide character that resembles WEOF; handle error */
  }
}

void f5(void) {
  int c;
  FILE *f = fopen("myfile", "r");

  do {
    c = getc(f);      // COMPLIANT
  } while (c != EOF); // NON_PORTABLE
}

void f6a(void) {
  int c;
  while ((c = getchar()) // COMPLIANT // NON_PORTABLE
         != EOF)
    ;
}
void f6b(void) {
  char c;
  while ((c = getchar()) != EOF) // NON_COMPLIANT
    ;
}

void f7(void) {
  int c;
  do {
    c = getchar();    // NON_COMPLIANT
    c = getchar();    // COMPLIANT
  } while (c != EOF); // NON_PORTABLE

  do {
    c = getchar();    // COMPLIANT
    if (c != EOF)     // NON_PORTABLE
      c = getchar();  // COMPLIANT
  } while (c != EOF); // NON_PORTABLE
}

// each call to getchar should be verified againt EOF
void f8(void) {
  int c;
  int i;
  for (i = 3; i > 0; i--) {
    c = getchar(); // NON_COMPLIANT
  }
  if (c != EOF) // NON_PORTABLE
    ;
}

void f9(void) {
  while (getchar() != EOF) // NON_PORTABLE
    ;                      // COMPLIANT

  int c;
  int c2;
  FILE *f = fopen("myfilef", "r");
  int d;
  FILE *g = fopen("myfileg", "r");

  c = getc(f);  // NON_COMPLIANT
  d = getc(g);  // COMPLIANT
  c2 = getc(f); // NON_COMPLIANT
  if (c != EOF) // NON_PORTABLE
    ;
  if (d != EOF) // NON_PORTABLE
    ;
}

int helper() { return ((!feof(stdin) && !ferror(stdin))); }
void finter(void) {
  int c;

  do {
    c = getchar(); // COMPLIANT[FALSE_POSITIVE]
  } while (helper());
}

// the char is compared to EOF
// but the result is not handled corectly
void fmishandling(void) {
  int c;

  do {
    c = getchar();    // NON_COMPLIANT[FALSE_NEGATIVE]
  } while (c == EOF); // NON_PORTABLE
}
