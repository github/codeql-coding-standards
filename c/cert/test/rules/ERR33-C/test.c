#include <inttypes.h>
#include <limits.h>
#include <locale.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <threads.h>
#include <time.h>
#include <wchar.h>

void *p;
typedef struct {
  char sig_desc[32];
} signal_info;

void f1(size_t n) {
  setlocale(LC_CTYPE, "en_US.UTF-8"); // NON_COMPLIANT

  const char *save1 = setlocale(LC_CTYPE, "en_US.UTF-8"); // COMPLIANT
  if (NULL == save1) {
  }

  const char *save2 = setlocale(LC_CTYPE, "en_US.UTF-8"); // NON_COMPLIANT
  if (save1 == save2) {
  }

  signal_info *start =
      (signal_info *)calloc(n, sizeof(signal_info)); // NON_COMPLIANT

  start = (signal_info *)calloc(n, sizeof(signal_info)); // COMPLIANT
  if (start == NULL) {
  }

  p = realloc(p, n); // NON_COMPLIANT
  if (p == NULL) {
  }

  void *q;
  q = realloc(p, n); // COMPLIANT
  if (q == NULL) {
  }
}

void f2(FILE *f, long o) {
  fseek(f, o, SEEK_SET); // NON_COMPLIANT

  if (fseek(f, o, SEEK_SET) != 0) { // COMPLIANT
  }

  char buf[40];
  snprintf(buf, sizeof(buf), ""); // NON_COMPLIANT

  int n = snprintf(buf, sizeof(buf), ""); // COMPLIANT
  if (n < 0) {
  }
}

void f3() {
  putchar('C');       // NON_COMPLIANT
  (void)putchar('C'); // COMPLIANT

  printf("");       // NON_COMPLIANT
  (void)printf(""); // COMPLIANT
}
void signal_handler(int signal) {}
void f4() {
  FILE *f;
  char a[10];
  char b[10];
  time_t time;
  if (fprintf(f, "") < 0) { // COMPLIANT
  }
  struct tm *local = localtime(&time);   // NON_COMPLIANT
  if (strftime(b, 10, "", local) == 0) { // COMPLIANT
  }
  if (clock() == (clock_t)(-1)) { // COMPLIANT
  }
  mblen(NULL, 0);          // COMPLIANT
  mblen(a, 0);             // NON_COMPLIANT
  if (mblen(a, 0) == -1) { // COMPLIANT
  }
  if (ftell(f) == -1L) { // COMPLIANT
  }
  if (fread(b, 1, 1, f) == 32) { // COMPLIANT
  }
  if (fwrite("", 1, 1, f) == 32) { // COMPLIANT
  }
  if (wctob(0) == EOF) { // COMPLIANT
  }
  if (fputc(0, f) == EOF) { // COMPLIANT
  }
  do {
    fputc(0, f); // COMPLIANT
  } while (!ferror(f));
  do {
    fputc(0, f); // NON_COMPLIANT
  } while (!feof(f));
  if (fgetc(f) == EOF) { // COMPLIANT
  }
  do {
    getchar(); // COMPLIANT
  } while ((!feof(stdin) && !ferror(stdin)));
  do {
    getchar(); // NON_COMPLIANT
  } while (!feof(stdin));
  if (aligned_alloc(0, 0) == NULL) { // COMPLIANT
  }
  if (signal(SIGINT, signal_handler) == SIG_ERR) { // COMPLIANT
  }
  cnd_t q;
  if (cnd_broadcast(&q) == thrd_error) { // COMPLIANT
  }
  if (cnd_init(&q) == thrd_nomem) { // COMPLIANT
  }
  if (cnd_init(&q) == thrd_error) { // COMPLIANT
  }
  mtx_t mutex;
  struct timespec ts;
  if (cnd_timedwait(&q, &mutex, &ts) == thrd_timedout) { // COMPLIANT
  }
  if (cnd_timedwait(&q, &mutex, &ts) == thrd_error) { // COMPLIANT
  }
  char *endptr;
  if (strtoumax("", &endptr, 0) == UINTMAX_MAX) { // COMPLIANT
  }
  if (strtoull("", &endptr, 0) == ULONG_MAX) { // NON_COMPLIANT
    // =ULLONG_MAX not present in the test DB
  }
  if (strtoul("", &endptr, 0) == ULONG_MAX) { // COMPLIANT
  }
  if (btowc(0) == WEOF) { // COMPLIANT
  }
  if (fgetwc(f) == WEOF) { // COMPLIANT
  }
  if (strxfrm(a, b, 10) >= 32) { // COMPLIANT
  }
}
