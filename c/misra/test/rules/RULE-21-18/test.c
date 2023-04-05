// test partially copied from CERT-C ARR38-C test
#include <stdlib.h>
#include <string.h>

char *get_ca_5(void) {
  void *ptr = malloc(5 * sizeof(char));
  memset(ptr, 0, 5 * sizeof(char));
  return (char *)ptr;
}

void test(void) {
  {
    char buf1[64];
    char buf2[64];
    memcpy(buf1, buf2, sizeof(buf1));         // COMPLIANT
    memcpy(buf1, buf2, sizeof(buf1) + 1);     // NON_COMPLIANT
    memcpy(buf1, buf2, sizeof(buf1) - 1);     // COMPLIANT
    memcpy(buf1 + 1, buf2, sizeof(buf1));     // NON_COMPLIANT
    memcpy(buf1, buf2 + 1, sizeof(buf1) * 2); // NON_COMPLIANT
  }
  {
    char buf1[64];
    char buf2[64];
    memcmp(buf1, buf2, sizeof(buf1));         // COMPLIANT
    memcmp(buf1, buf2, sizeof(buf1) + 1);     // NON_COMPLIANT
    memcmp(buf1, buf2, sizeof(buf1) - 1);     // COMPLIANT
    memcmp(buf1 + 1, buf2, sizeof(buf1));     // NON_COMPLIANT
    memcmp(buf1, buf2 + 1, sizeof(buf1) * 2); // NON_COMPLIANT
  }
  {
    char buf[128];
    memchr(buf, 0, sizeof(buf));     // COMPLIANT
    memchr(buf, 0, sizeof(buf) + 1); // NON_COMPLIANT
    memchr(buf, 0, sizeof(buf) + 1); // NON_COMPLIANT
    memchr(buf, 0, sizeof(buf) - 1); // COMPLIANT
    memchr(NULL, 0, sizeof(buf));    // NON_COMPLIANT
  }
  {
    char buf[128];
    memset(buf, 0, sizeof(buf));     // COMPLIANT
    memset(buf, 0, sizeof(buf) + 1); // NON_COMPLIANT
    memset(buf, 0, sizeof(buf) + 1); // NON_COMPLIANT
    memset(buf, 0, sizeof(buf) - 1); // COMPLIANT
    memset(NULL, 0, sizeof(buf));    // NON_COMPLIANT
  }
  {
    char buf1[128];
    char buf2[256];
    memmove(buf1, buf2, sizeof(buf1));     // COMPLIANT
    memmove(buf1, buf2, sizeof(buf1) + 1); // NON_COMPLIANT
    memmove(buf1, buf2, sizeof(buf1) - 1); // COMPLIANT
    memmove(buf1 + 1, buf2, sizeof(buf1)); // NON_COMPLIANT
    memmove(buf1, buf2 + 1, sizeof(buf1)); // COMPLIANT
    memmove(buf2, buf1, sizeof(buf2));     // NON_COMPLIANT
    memmove(buf2, buf1, sizeof(buf1));     // COMPLIANT
  }
  {
    char buf1[128];
    char buf2[256] = {0};
    strncpy(buf2, buf1, sizeof(buf1));     // COMPLIANT
    strncpy(buf1, buf2, sizeof(buf1));     // COMPLIANT
    strncpy(buf1, buf2, sizeof(buf1) + 1); // NON_COMPLIANT
    strncpy(buf1, buf2, sizeof(buf1) - 1); // COMPLIANT
    strncpy(buf1 + 1, buf2, sizeof(buf1)); // NON_COMPLIANT
  }
  {
    char buf0[10]; // memset after first use
    char buf1[10]; // no memset
    char buf2[10]; // memset before first use
    char buf3[10] = {'\0'};
    char buf4[10] = "12345";

    strncat(buf0, " ",
            1); // NON_COMPLIANT[FALSE_NEGATIVE] - buf0 not null-terminated
    memset(buf0, 0, sizeof(buf0));   // COMPLIANT
    memset(buf2, 0, sizeof(buf2));   // COMPLIANT
    strncat(buf1, " ", 1);           // NON_COMPLIANT - not null-terminated
    strncat(buf2, " ", 1);           // COMPLIANT
    strncat(buf3, " ", 1);           // COMPLIANT
    strncat(buf4, "12345", 5);       // NON_COMPLIANT[FALSE_NEGATIVE]
    strncat(get_ca_5(), "12345", 5); // NON_COMPLIANT - null-terminator past end
    strncat(get_ca_5(), "1234", 4);  // COMPLIANT
    strncat(get_ca_5() + 1, "1234", 4); // NON_COMPLIANT
    strncat(get_ca_5(), "12", 2);       // COMPLIANT
  }
  {
    char ca5_good[5] = "test";      // ok
    char ca5_bad[5] = "test1";      // no null terminator
    char ca6_good[6] = "test1";     // ok
    strncmp(ca5_good, ca5_bad, 4);  // COMPLIANT
    strncmp(ca5_good, ca5_bad, 5);  // COMPLIANT
    strncmp(ca6_good, ca5_bad, 5);  // COMPLIANT
    strncmp(ca6_good, ca5_good, 6); // COMPLIANT[FALSE_POSITIVE]
    strncmp(ca5_good, ca5_bad, 6);  // NON_COMPLIANT
  }
  // strxfrm
  {
    char buf[64];
    char buf2[128];
    strxfrm(buf, "abc", sizeof(buf));     // COMPLIANT
    strxfrm(buf, "abc", sizeof(buf) + 1); // NON_COMPLIANT
    strxfrm(buf, "abc", sizeof(buf) - 1); // COMPLIANT
    strxfrm(buf + 1, buf2,
            sizeof(buf) - 1); // NON_COMPLIANT - not null-terminated
  }
}