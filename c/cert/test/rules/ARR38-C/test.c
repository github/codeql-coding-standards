#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <wchar.h>

char *get_ca_5(void) {
  void *ptr = malloc(5 * sizeof(char));
  memset(ptr, 0, 5 * sizeof(char));
  return (char *)ptr;
}

int compare(void *a, void *b) {}

void test_strings_loop(void) {
  char ca5[5] = "test"; // ok
  char buf5[5] = {0};

  for (int i = 0; i < 5; i++) {
    strcpy(buf5, ca5);         // COMPLIANT
    strcpy(buf5 + i, ca5);     // NON_COMPLIANT[FALSE_NEGATIVE]
    strncpy(buf5, ca5, i);     // COMPLIANT
    strncpy(buf5, ca5, i + 1); // NON_COMPLIANT[FALSE_NEGATIVE]
  }
}

void test_strings(int flow, int unk_size) {
  char ca5_good[5] = "test";  // ok
  char ca5_bad[5] = "test1";  // no null terminator
  char ca6_good[6] = "test1"; // ok
  char ca6_bad[6] = "test12"; // no null terminator

  wchar_t wa5_good[5] = L"test";  // ok
  wchar_t wa5_bad[5] = L"test1";  // no null terminator
  wchar_t wa6_good[6] = L"test";  // ok
  wchar_t wa6_bad[6] = L"test12"; // no null terminator

  // strchr
  strchr(ca5_good, 't');     // COMPLIANT
  strchr(ca5_bad, 't');      // NON_COMPLIANT
  strchr(ca5_good + 4, 't'); // COMPLIANT
  strchr(ca5_good + 5, 't'); // NON_COMPLIANT

  if (flow) {
    // strcpy from literal
    strcpy(ca5_good, "test1"); // NON_COMPLIANT
    strcpy(ca5_bad, "test");   // COMPLIANT
  }

  if (flow) {
    // strcpy to char buffer indirect
    strcpy(get_ca_5(), ca5_good); // COMPLIANT
    strcpy(get_ca_5(), ca5_bad);  // NON_COMPLIANT
    strcpy(get_ca_5(), ca6_good); // NON_COMPLIANT
  }

  // strcpy between string buffers (must be null-terminated)
  if (flow) {
    strcpy(ca5_good, ca6_good);
  } // NON_COMPLIANT
  if (flow) {
    strcpy(ca5_good, ca6_bad);
  } // NON_COMPLIANT
  if (flow) {
    strcpy(ca5_bad, ca6_good);
  } // NON_COMPLIANT
  if (flow) {
    strcpy(ca6_bad, ca5_good);
  } // COMPLIANT
  if (flow) {
    strcpy(ca6_bad, ca5_bad);
  } // NON_COMPLIANT
  if (flow) {
    strcpy(get_ca_5(), ca5_good);
  } // COMPLIANT
  if (flow) {
    strcpy(get_ca_5(), ca5_bad);
  } // NON_COMPLIANT
  if (flow) {
    strcpy(get_ca_5(), ca6_good);
  } // NON_COMPLIANT
  if (flow) {
    strcpy(ca5_good, get_ca_5());
  } // NON_COMPLIANT[FALSE_NEGATIVE]

  // strncpy between char buffers (does not have to be null-terminated)
  if (flow) {
    strncpy(ca5_good, ca6_good, 4);
  } // COMPLIANT
  if (flow) {
    strncpy(ca5_good, ca6_good, 5);
  } // COMPLIANT
  if (flow) {
    strncpy(ca5_good, ca6_bad, 4);
  } // COMPLIANT
  if (flow) {
    strncpy(ca5_good, ca5_good, 5);
  } // COMPLIANT
  if (flow) {
    strncpy(ca5_bad, ca5_bad, 5);
  } // COMPLIANT
  if (flow) {
    strncpy(ca5_bad, ca5_good, 6);
  } // NON_COMPLIANT
  if (flow) {
    strncpy(ca6_bad, ca5_good, 5);
  } // COMPLIANT
  if (flow) {
    strncpy(ca6_bad, ca5_good, 6);
  } // COMPLIANT
  if (flow) {
    strncpy(ca5_good + 1, ca5_good + 2, 3);
  } // COMPLIANT
  if (flow) {
    strncpy(ca5_good + 1, ca5_good + 2, 2);
  } // COMPLIANT

  // wrong allocation size
  char *p1 = malloc(strlen(ca5_good) + 1);
  char *p2 = malloc(strlen(ca5_good));

  // memcpy with strings and strlen
  if (flow) {
    memcpy(p1, ca5_good, strlen(ca5_good) + 1);
  } // COMPLIANT
  if (flow) {
    memcpy(p2, ca5_good, strlen(ca5_good) + 1);
  } // NON_COMPLIANT
  if (flow) {
    memcpy(p2 + 1, ca5_good, strlen(ca5_good) - 1);
  } // COMPLIANT
  if (flow) {
    memcpy(p1, ca5_good, strlen(ca5_good));
  } // COMPLIANT - but not terminated
  if (flow) {
    memcpy(p2, ca5_good, strlen(ca5_good));
  } // COMPLIANT - but not terminated

  // strcat
  if (flow) {
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
    strcat(buf4, "12345"); // NON_COMPLIANT

    strcat(get_ca_5(), "12345");    // NON_COMPLIANT
    strcat(get_ca_5(), "1234");     // COMPLIANT
    strcat(get_ca_5() + 1, "1234"); // NON_COMPLIANT
  }

  // wcsncat
  if (flow) {
    wchar_t buf0[10]; // memset after first use
    wchar_t buf1[10]; // no memset
    wchar_t buf2[10]; // memset before first use
    wchar_t buf3[10] = {L'\0'};
    wchar_t buf4[10] = L"12345";

    wcsncat(buf0, L" ",
            1); // NON_COMPLIANT[FALSE_NEGATIVE] - not null terminated at
                // initialization

    memset(buf0, 0, sizeof(buf0)); // COMPLIANT
    memset(buf2, 0, sizeof(buf2)); // COMPLIANT

    wcsncat(buf1, L" ", 1);     // NON_COMPLIANT - not null terminated
    wcsncat(buf2, L" ", 1);     // COMPLIANT
    wcsncat(buf3, L" ", 1);     // COMPLIANT
    wcsncat(buf4, L"12345", 5); // NON_COMPLIANT[FALSE_NEGATIVE]

    wcsncat(get_ca_5(), L"12345", 5);    // NON_COMPLIANT
    wcsncat(get_ca_5(), L"1234", 4);     // NON_COMPLIANT
    wcsncat(get_ca_5() + 1, L"1234", 4); // NON_COMPLIANT
    wcsncat(get_ca_5(), L"12", 2);       // NON_COMPLIANT
  }

  // strcmp
  if (flow) {
    strcmp(ca5_good, ca5_bad);  // NON_COMPLIANT
    strcmp(ca5_good, ca5_good); // COMPLIANT
    strcmp(ca5_bad, ca5_good);  // NON_COMPLIANT
    strcmp(ca5_good, ca6_good); // COMPLIANT
    strcmp(ca6_good, ca5_good); // COMPLIANT
  }

  // strncmp
  if (flow) {
    strncmp(ca5_good, ca5_bad, 4); // COMPLIANT
    strncmp(ca5_good, ca5_bad, 5); // COMPLIANT
    strncmp(ca5_good, ca5_bad, 6); // NON_COMPLIANT
  }
}

void test_wrong_buf_size(void) {

  // fgets
  {
    char buf[128];
    fgets(buf, sizeof(buf), stdin);         // COMPLIANT
    fgets(buf, sizeof(buf) - 1, stdin);     // COMPLIANT
    fgets(buf, sizeof(buf) + 1, stdin);     // NON_COMPLIANT
    fgets(buf, 0, stdin);                   // COMPLIANT
    fgets(buf + 1, sizeof(buf) - 1, stdin); // COMPLIANT
    fgets(buf + 1, sizeof(buf), stdin);     // NON_COMPLIANT
  }

  // fgetws
  {
    wchar_t wbuf[128];
    fgetws(wbuf, sizeof(wbuf), stdin);                         // NON_COMPLIANT
    fgetws(wbuf, sizeof(wbuf) / sizeof(*wbuf), stdin);         // COMPLIANT
    fgetws(wbuf, sizeof(wbuf) / sizeof(*wbuf) - 1, stdin);     // COMPLIANT
    fgetws(wbuf, sizeof(wbuf) / sizeof(*wbuf) + 1, stdin);     // NON_COMPLIANT
    fgetws(wbuf, 0, stdin);                                    // COMPLIANT
    fgetws(wbuf + 1, sizeof(wbuf) / sizeof(*wbuf) - 2, stdin); // COMPLIANT
    fgetws(wbuf + 1, sizeof(wbuf) / sizeof(*wbuf), stdin);     // NON_COMPLIANT
  }

  // mbstowcs
  {
    char buf1[128] = {0};
    char buf2[128];
    wchar_t wbuf[128];

    mbstowcs(wbuf, buf1, sizeof(wbuf)); // NON_COMPLIANT - count too large
    mbstowcs(wbuf, buf1, sizeof(buf1)); // COMPLIANT - but wrong arithmetic
    mbstowcs(wbuf, buf2,
             sizeof(wbuf) /
                 sizeof(wchar_t)); // NON_COMPLIANT - not null-terminated
    mbstowcs(wbuf, buf1, sizeof(wbuf) / sizeof(wchar_t)); // COMPLIANT
  }

  // wcstombs
  {
    char buf[128];
    wchar_t wbuf[128] = {0};
    wcstombs(buf, wbuf, sizeof(wbuf)); // NON_COMPLIANT - count too large
    wcstombs(buf, wbuf, sizeof(buf));  // COMPLIANT
    wcstombs(buf + 1, wbuf + 1, sizeof(buf) - 1); // COMPLIANT
    wcstombs(buf + 1, wbuf + 1, sizeof(buf));     // NON_COMPLIANT
  }

  // mbtowc
  {
    wchar_t c;
    char buf[2] = {0};
    mbtowc(&c, buf, sizeof(buf));     // COMPLIANT
    mbtowc(&c, buf, sizeof(buf) - 1); // COMPLIANT
    mbtowc(&c, buf, sizeof(buf) + 1); // NON_COMPLIANT
    mbtowc(NULL, NULL, 0);            // COMPLIANT - exception
  }

  // mblen
  {
    char buf[3] = {0};
    mblen(buf, sizeof(buf));                   // COMPLIANT
    mblen(buf, sizeof(buf) + 1);               // NON_COMPLIANT
    mblen((char *)malloc(5), sizeof(buf) * 2); // NON_COMPLIANT
    mblen(NULL, 0);                            // COMPLIANT - exception
  }

  // memchr, memset
  {
    char buf[128];
    memchr(buf, 0, sizeof(buf));     // COMPLIANT
    memchr(buf, 0, sizeof(buf) + 1); // NON_COMPLIANT
    memset(buf, 0, sizeof(buf) + 1); // NON_COMPLIANT
    memchr(buf, 0, sizeof(buf) - 1); // COMPLIANT
    memchr(NULL, 0, sizeof(buf));    // NON_COMPLIANT
  }

  // strftime
  {
    char buf[128];
    strftime(buf, sizeof(buf), "%Y-%m-%d", NULL);     // COMPLIANT
    strftime(buf, sizeof(buf) + 1, "%Y-%m-%d", NULL); // NON_COMPLIANT
    strftime(buf, sizeof(buf) - 1, "%Y-%m-%d", NULL); // COMPLIANT
    strftime(buf + 1, sizeof(buf), "%Y-%m-%d", NULL); // NON_COMPLIANT
  }

  // wcsftime
  {
    wchar_t wbuf[128] = {0};
    wchar_t format_bad[8] = L"%Y-%m-%d";
    wcsftime(wbuf, sizeof(wbuf) / sizeof(wchar_t), L"%Y-%m-%d",
             NULL); // COMPLIANT
    wcsftime(wbuf, sizeof(wbuf) / sizeof(wchar_t) + 2, L"%Y-%m-%d",
             NULL); // NON_COMPLIANT
    wcsftime(wbuf, sizeof(wbuf) / sizeof(wchar_t) - 2, L"%Y-%m-%d",
             NULL); // COMPLIANT
    wcsftime(wbuf, sizeof(wbuf) / sizeof(wchar_t), format_bad,
             NULL); // NON_COMPLIANT
    wcsftime(wbuf + 1, sizeof(wbuf) / sizeof(wchar_t), L"%Y-%m-%d",
             NULL);                                  // NON_COMPLIANT
    wcsftime(wbuf, sizeof(wbuf), L"%Y-%m-%d", NULL); // NON_COMPLIANT
  }

  // strxfrm
  {
    char buf[64];
    char buf2[128];
    strxfrm(buf, "abc", sizeof(buf));     // COMPLIANT
    strxfrm(buf, "abc", sizeof(buf) + 1); // NON_COMPLIANT
    strxfrm(buf, "abc", sizeof(buf) - 1); // COMPLIANT
    strxfrm(buf + 1, buf2,
            sizeof(buf) - 1); // NON_COMPLIANT - not null terminated
  }

  // wcsxfrm
  {
    wchar_t wbuf[64];
    wchar_t wbuf2[128];
    wcsxfrm(wbuf, L"abc", sizeof(wbuf) / sizeof(wchar_t));     // COMPLIANT
    wcsxfrm(wbuf, L"abc", sizeof(wbuf) / sizeof(wchar_t) + 1); // NON_COMPLIANT
    wcsxfrm(wbuf, L"abc", sizeof(wbuf) / sizeof(wchar_t) - 1); // COMPLIANT
    wcsxfrm(wbuf + 1, wbuf2, sizeof(wbuf) / sizeof(wchar_t) - 1); // COMPLIANT
  }

  // snprintf (and vsnprintf, swprintf, vswprintf)
  {
    char str_bad[2] = "12";
    char buf[64];
    snprintf(buf, sizeof(buf), "%s", ""); // COMPLIANT
    snprintf(buf, sizeof(buf), "%s",
             str_bad); // NON_COMPLIANT[FALSE_NEGATIVE] - not checked
    snprintf(buf, sizeof(buf) + 1, "test"); // NON_COMPLIANT
  }

  // setvbuf
  {
    FILE *f;
    char buf[64];
    setvbuf(f, buf, _IOFBF, sizeof(buf));     // COMPLIANT
    setvbuf(f, buf, _IOFBF, sizeof(buf) + 1); // NON_COMPLIANT
    setvbuf(f, buf, _IOFBF, sizeof(buf) - 1); // COMPLIANT
    setvbuf(f, buf + 1, _IOFBF, sizeof(buf)); // NON_COMPLIANT
    setvbuf(f, NULL, _IOFBF, 0);              // COMPLIANT - exception
  }

  // "memcpy", "wmemcpy", "memmove", "wmemmove", "memcmp", "wmemcmp"

  // memcpy
  {
    char buf[64];
    char buf2[64];
    wchar_t wbuf[64];
    wchar_t wbuf2[64];

    memcpy(buf, buf2, sizeof(buf));         // COMPLIANT
    memcpy(buf, buf2, sizeof(buf) + 1);     // NON_COMPLIANT
    memcpy(buf, buf2, sizeof(buf) - 1);     // COMPLIANT
    memcpy(buf + 1, buf2, sizeof(buf));     // NON_COMPLIANT
    memcpy(buf, buf2 + 1, sizeof(buf) * 2); // NON_COMPLIANT
  }

  // wmemcpy
  {
    wchar_t wbuf128[128];
    wchar_t wbuf64[64];

    wmemcpy(wbuf128, wbuf64, sizeof(wbuf64) / sizeof(wchar_t)); // COMPLIANT
    wmemcpy(wbuf128, wbuf64,
            sizeof(wbuf128) / sizeof(wchar_t)); // NON_COMPLIANT
    wmemcpy(wbuf128, wbuf64, sizeof(wbuf64) / sizeof(wchar_t) - 1); // COMPLIANT
    wmemcpy(wbuf64 + 1, wbuf64,
            sizeof(wbuf64) / sizeof(wchar_t)); // NON_COMPLIANT
    wmemcpy(wbuf64 + 1, wbuf64 + 1,
            sizeof(wbuf64) / sizeof(wchar_t)); // NON_COMPLIANT
    wmemcpy(wbuf64 + 1, wbuf64 + 1,
            sizeof(wbuf64) / sizeof(wchar_t) - 1); // NON_COMPLIANT
    wmemcpy(wbuf64 + 1, wbuf64 + 1,
            sizeof(wbuf64) / sizeof(wchar_t) - 2); // COMPLIANT
  }

  // bsearch
  {
    int arr[10];
    int key = 0;
    bsearch(&key, arr, sizeof(arr) / sizeof(int), sizeof(int),
            compare); // COMPLIANT
    bsearch(&key, arr, sizeof(arr) / sizeof(int) + 1, sizeof(int),
            compare); // NON_COMPLIANT
    bsearch(&key, arr, sizeof(arr) / sizeof(int) - 1, sizeof(int),
            compare); // COMPLIANT
    bsearch(&key, arr + 1, sizeof(arr) / sizeof(int) - 1, sizeof(int),
            compare); // NON_COMPLIANT
    bsearch(NULL, arr, sizeof(arr) / sizeof(int), sizeof(int),
            compare); // NON_COMPLIANT
    bsearch(&key, NULL, sizeof(arr) / sizeof(int), sizeof(int),
            compare); // NON_COMPLIANT
    bsearch(&key, arr, sizeof(arr) / sizeof(int), sizeof(int),
            NULL); // NON_COMPLIANT
  }

  // qsort
  {
    int arr[10];
    qsort(arr, sizeof(arr) / sizeof(int), sizeof(int), compare); // COMPLIANT
    qsort(arr, sizeof(arr) / sizeof(int) + 1, sizeof(int),
          compare); // NON_COMPLIANT
    qsort(arr, sizeof(arr) / sizeof(int) - 1, sizeof(int),
          compare); // COMPLIANT
    qsort(arr + 1, sizeof(arr) / sizeof(int) - 1, sizeof(int),
          compare);                                           // NON_COMPLIANT
    qsort(arr, sizeof(arr) / sizeof(int), sizeof(int), NULL); // NON_COMPLIANT
  }
}

void test_fread_fwrite_static(char *file_name) {
  FILE *f = fopen(file_name, "r");
  char buf[64];
  fread(buf, sizeof(buf), 1, f);      // COMPLIANT
  fread(buf, sizeof(buf) + 1, 1, f);  // NON_COMPLIANT
  fread(buf, sizeof(buf) - 1, 1, f);  // COMPLIANT
  fread(buf + 1, sizeof(buf), 1, f);  // NON_COMPLIANT
  fread(buf, sizeof(buf) * 2, 1, f);  // NON_COMPLIANT
  fwrite(buf, sizeof(buf), 1, f);     // COMPLIANT
  fwrite(buf, sizeof(buf) + 1, 1, f); // NON_COMPLIANT
  fwrite(buf, sizeof(buf) - 1, 1, f); // COMPLIANT
  fwrite(buf + 1, sizeof(buf), 1, f); // NON_COMPLIANT
  fwrite(buf, sizeof(buf) * 2, 1, f); // NON_COMPLIANT
  fclose(f);
}

void test_read_file(const char *file_name) {
  FILE *f = fopen(file_name, "rb");

  fseek(f, 0, SEEK_END);
  long len = ftell(f);
  rewind(f);

  char *buf = malloc(len + 1);

  // not correct behaviour below but suffices to test overflow
  rewind(f);
  fread(buf + 1, len - 1, 1, f); // COMPLIANT
  rewind(f);
  fread(buf + 1, len, 1, f); // COMPLIANT
  rewind(f);
  fread(buf + 1, len + 1, 1, f); // COMPLIANT
  rewind(f);
  fread(buf + 1, len + 2, 1, f); // COMPLIANT
  rewind(f);
  fread(buf + 1, len + 3, 1, f); // NON_COMPLIANT

  fclose(f);
}

void test_equivalent_expressions(void *in, int x, int y, int a, int b) {
  short *p = malloc(x * y * sizeof(short));
  memcpy(p, in, x * y * sizeof(short));     // COMPLIANT
  memcpy(p, in, x * y * sizeof(short) + 1); // NON_COMPLIANT
  memcpy(p, in, x * y * sizeof(short) - 1); // COMPLIANT
  memcpy(p, in, a * b * sizeof(short) + 1); // COMPLIANT - unknown
}