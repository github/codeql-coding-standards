#define __STDC_WANT_LIB_EXT1__ 1
#include <stdio.h>
#include <time.h>

void f1a(struct tm *time_tm) {
  char *time = asctime(time_tm); // NON_COMPLIANT
  /* ... */
}

void f1b() {
  time_t ltime;
  /* Get the time in seconds */
  time(&ltime);
  /* Convert it to the structure tm */
  struct tm *time_tm = localtime(&ltime);
  char *time = asctime(time_tm); // COMPLIANT
}

enum { maxsize = 26 };

void f2(struct tm *time) {
  char s[maxsize];
  /* Current time representation for locale */
  const char *format = "%c";

  size_t size = strftime(s, maxsize, format, time);
}

#ifdef __STDC_LIB_EXT1__
void f3(struct tm *time_tm) {
  char buffer[maxsize];

  if (asctime_s(buffer, maxsize, &time_tm)) {
    /* Handle error */
  }
}
#endif