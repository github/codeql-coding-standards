// test partially copied from CERT-C ARR38-C test
#include <stdlib.h>
#include <string.h>

char *get_ca_5(void) {
  void *ptr = malloc(5 * sizeof(char));
  memset(ptr, 0, 5 * sizeof(char));
  return (char *)ptr;
}

void test(void) {
  char ca5_good[5] = "test";  // ok
  char ca5_bad[5] = "test1";  // no null terminator
  char ca6_good[6] = "test1"; // ok
  char ca6_bad[6] = "test12"; // no null terminator

  // strcat
  {
    char buf0[10]; // memset after first use
    char buf1[10]; // no memset
    char buf2[10]; // memset before first use
    char buf3[10] = {'\0'};
    char buf4[10] = "12345";

    strcat(buf0, " "); // NON_COMPLIANT[FALSE_NEGATIVE] - not null terminated at
                       // initialization

    memset(buf0, 0, sizeof(buf0)); // COMPLIANT
    memset(buf2, 0, sizeof(buf2)); // COMPLIANT

    strcat(buf1, " ");     // NON_COMPLIANT - not null terminated
    strcat(buf2, " ");     // COMPLIANT
    strcat(buf3, " ");     // COMPLIANT
    strcat(buf4, "12345"); // NON_COMPLIANT[FALSE_NEGATIVE]

    strcat(get_ca_5(), "12345");    // NON_COMPLIANT
    strcat(get_ca_5(), "1234");     // COMPLIANT
    strcat(get_ca_5() + 1, "1234"); // NON_COMPLIANT
  }
  // strchr and strrchr
  {
    strchr(ca5_good, 't');     // COMPLIANT
    strchr(ca5_bad, 't');      // NON_COMPLIANT
    strchr(ca5_good + 4, 't'); // COMPLIANT
    strchr(ca5_good + 5, 't'); // NON_COMPLIANT
    strrchr(ca5_good, 1);      // COMPLIANT
    strrchr(ca5_bad, 1);       // NON_COMPLIANT
    strrchr(ca5_good + 4, 1);  // COMPLIANT
    strrchr(ca5_good + 5, 1);  // NON_COMPLIANT
  }
  // strcmp and strcoll
  {
    strcmp(ca5_good, ca5_bad);   // NON_COMPLIANT
    strcmp(ca5_good, ca5_good);  // COMPLIANT
    strcmp(ca5_bad, ca5_good);   // NON_COMPLIANT
    strcmp(ca5_good, ca6_good);  // COMPLIANT
    strcmp(ca6_good, ca5_good);  // COMPLIANT
    strcoll(ca5_good, ca5_bad);  // NON_COMPLIANT
    strcoll(ca5_good, ca5_good); // COMPLIANT
    strcoll(ca5_bad, ca5_good);  // NON_COMPLIANT
    strcoll(ca5_good, ca6_good); // COMPLIANT
    strcoll(ca6_good, ca5_good); // COMPLIANT
  }
  // strcpy
  {
    strcpy(ca5_good, "test1"); // NON_COMPLIANT
    strcpy(ca5_bad, "test");   // COMPLIANT
    // strcpy to char buffer indirect
    strcpy(get_ca_5(), ca5_good); // COMPLIANT
    strcpy(get_ca_5(), ca5_bad);  // NON_COMPLIANT
    strcpy(get_ca_5(), ca6_good); // NON_COMPLIANT
  }
  // strcspn and strspn
  {
    strcspn(ca5_good, "test");       // COMPLIANT
    strcspn(ca5_bad, "test");        // NON_COMPLIANT - not null-terminated
    strcspn(ca5_good, "1234567890"); // COMPLIANT
    strcspn(NULL, "12345");          // NON_COMPLIANT
    strspn(ca5_good, "test");        // COMPLIANT
    strspn(ca5_bad, "test");         // NON_COMPLIANT - not null-terminated
    strspn(ca5_good, "1234567890");  // COMPLIANT
    strspn(NULL, "12345");           // NON_COMPLIANT
  }
  // strlen
  {
    strlen(ca5_bad);      // NON_COMPLIANT
    strlen(ca5_good + 4); // COMPLIANT
    strlen(ca5_good + 5); // NON_COMPLIANT
  }
  // strpbrk
  {
    strpbrk(ca5_good, "test");       // COMPLIANT
    strpbrk(ca5_bad, "test");        // NON_COMPLIANT - not null-terminated
    strpbrk(ca5_good, "1234567890"); // COMPLIANT
    strpbrk(NULL, "12345");          // NON_COMPLIANT
  }
  // strstr
  {
    strstr("12345", "123");         // COMPLIANT
    strstr("123", "12345");         // COMPLIANT
    strstr(ca5_good, "test");       // COMPLIANT
    strstr(ca5_bad, "test");        // NON_COMPLIANT - not null-terminated
    strstr(ca5_good, "1234567890"); // COMPLIANT
  }
  // strtok
  {
    char ca5_good[5] = "test";  // ok
    char ca5_bad[5] = "test1";  // no null terminator
    char ca6_good[6] = "test1"; // ok
    char ca6_bad[6] = "test12"; // no null terminator
    strtok(NULL, NULL);         // NON_COMPLIANT - 2nd arg null
    strtok(NULL, "");           // COMPLIANT
    strtok(ca5_bad, "");        // NON_COMPLIANT - 1st arg not null-terminated
    strtok(ca5_good, "");       // COMPLIANT
    strtok(ca6_good, ca5_good); // COMPLIANT
    strtok(ca6_good + 4, ca6_good); // COMPLIANT
    strtok(ca6_good, ca6_bad); // NON_COMPLIANT - 2nd arg not null-terminated
  }
}