#include <cstdlib>
#include <cstring>
#include <ctime>
#include <cwchar>

void stack_allocated_single_dimensional_pointer_arithmetic(int *array) {
  /* 1. Pointer formed from performing arithmetic */
  int *valid1 = array;     // COMPLIANT: pointer is within boundary
  int *valid2 = array + 1; // COMPLIANT: pointer is within boundary
  int *valid3 = array + 2; // COMPLIANT: pointer is within boundary
  int *valid4 =
      array + 3; // COMPLIANT: pointer points one beyond the last element
  int *invalid1 =
      array +
      4; // NON_COMPLIANT: pointer points more than one beyond the last element
  int *invalid2 = array - 1; // NON_COMPLIANT: pointer is outside boundary
}

void stack_allocated_single_dimensional_array_access(int *array) {
  /* 2. Array Access (entails pointer arithmetic) */
  int valid1 = array[0];   // COMPLIANT: pointer is within boundary
  int valid2 = array[1];   // COMPLIANT: pointer is within boundary
  int valid3 = array[2];   // COMPLIANT: pointer is within boundary
  int valid4 = array[3];   // COMPLIANT: pointer points one beyond the last
                           // element, but non-compliant to Rule 4.1.3
  int invalid1 = array[4]; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element
  int invalid2 = array[-1]; // NON_COMPLIANT: pointer is outside boundary
}

void malloc_single_dimensional_pointer_arithmetic(int *array) { // [1, 4]
  /* 1. Pointer formed from performing arithmetic */
  int *valid1 = array; // COMPLIANT: pointer is within boundary (lower bound: 1)
  int *valid2 = array + 1; // COMPLIANT: pointer points more than one beyond the
                           // last element (lower bound: 1)
  int *valid3 = array + 2; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 1)
  int *valid4 = array + 3; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 1)
  int *invalid1 = array + 4; // NON_COMPLIANT: pointer points more than one
                             // beyond the last element (lower bound: 1)
  int *invalid2 = array + 5; // NON_COMPLIANT: pointer points more than one
                             // beyond the last element (lower bound: 1)
  int *invalid3 = array - 1; // NON_COMPLIANT: pointer is outside boundary
}

void malloc_single_dimensional_array_access(int *array) { // [1, 4]
  /* 2. Array Access (entails pointer arithmetic) */
  int valid1 =
      array[0]; // COMPLIANT: pointer is within boundary (lower bound: 1)
  int valid2 = array[1]; // COMPLIANT: pointer points more than one beyond the
                         // last element, but non-compliant to Rule 4.1.3 (lower
                         // bound: 1)
  int valid3 = array[2]; // NON_COMPLIANT: pointer points more than one beyond
                         // the last element (lower bound: 1)
  int valid4 = array[3]; // NON_COMPLIANT: pointer points more than one beyond
                         // the last element (lower bound: 1)
  int invalid1 = array[4]; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 1)
  int invalid2 = array[-1]; // NON_COMPLIANT: pointer is outside boundary
}

void calloc_single_dimensional_pointer_arithmetic(int *array) { // [2, 5]
  /* 1. Pointer formed from performing arithmetic */
  int *valid1 = array; // COMPLIANT: pointer is within boundary (lower bound: 2)
  int *valid2 =
      array + 1; // COMPLIANT: pointer is within boundary (lower bound: 2)
  int *valid3 = array + 2; // COMPLIANT: pointer points more than one beyond the
                           // last element, but non-compliant to Rule 4.1.3
                           // (lower bound: 2)
  int *valid4 = array + 3; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 2)
  int *invalid1 = array + 4; // NON_COMPLIANT: pointer points more than one
                             // beyond the last element (lower bound: 2)
  int *invalid2 = array - 1; // NON_COMPLIANT: pointer is outside boundary
}

void calloc_single_dimensional_array_access(int *array) { // [2, 5]
  /* 2. Array Access (entails pointer arithmetic) */
  int valid1 = array[0];   // COMPLIANT: pointer is within boundary
  int valid2 = array[1];   // COMPLIANT: pointer is within boundary
  int valid3 = array[2];   // COMPLIANT: pointer points more than one beyond the
                           // last element, but non-compliant to Rule 4.1.3
                           // (lower bound: 2)
  int valid4 = array[3];   // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 2)
  int invalid1 = array[4]; // NON_COMPLIANT: pointer points more than one
                           // beyond the last element (lower bound: 2)
  int invalid2 = array[-1]; // NON_COMPLIANT: pointer is outside boundary
}

void realloc_single_dimensional_pointer_arithmetic(int *array) { // [3, 6]
  /* 1. Pointer formed from performing arithmetic */
  int *valid1 = array; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int *valid2 =
      array + 1; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int *valid3 =
      array + 2; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int *valid4 = array + 3;   // COMPLIANT: pointer points one beyond the last
                             // element (lower bound: 3)
  int *invalid1 = array + 4; // NON_COMPLIANT: pointer points more than one
                             // beyond the last element (lower bound: 3)
  int *invalid2 = array - 1; // NON_COMPLIANT: pointer is outside boundary
}

void realloc_single_dimensional_array_access(int *array) { // [3, 6]
  /* 2. Array Access (entails pointer arithmetic) */
  int valid1 =
      array[0]; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int valid2 =
      array[1]; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int valid3 =
      array[2]; // COMPLIANT: pointer is within boundary (lower bound: 3)
  int valid4 =
      array[3]; // COMPLIANT: pointer points one beyond the last
                // element, but non-compliant to Rule 4.1.3 (lower bound: 3)
  int invalid1 = array[4]; // NON_COMPLIANT: pointer points more than one beyond
                           // the last element (lower bound: 3)
  int invalid2 = array[-1]; // NON_COMPLIANT: pointer is outside boundary
}

void stack_allocated_multi_dimensional_array_access(int array[2][3]) {
  int valid11 = array[0][0];  // COMPLIANT: pointer is within boundary
  int valid12 = array[0][1];  // COMPLIANT: pointer is within boundary
  int valid13 = array[0][2];  // COMPLIANT: pointer points one beyond the last
                              // element, but non-compliant to Rule 4.1.3
  int invalid1 = array[0][3]; // NON_COMPLIANT: pointer points more than one
                              // beyond the last element

  int valid21 = array[1][0]; // COMPLIANT: pointer is within boundary
  int valid22 = array[1][1]; // COMPLIANT: pointer is within boundary
  int valid23 = array[1][2]; // COMPLIANT: pointer points one beyond the last
                             // element, but non-compliant to Rule 4.1.3

  int invalid2 = array[1][3]; // NON_COMPLIANT: pointer points more than one
                              // beyond the last element

  int valid31 = array[2][0];  // COMPLIANT: pointer points one beyond the last
                              // element, but non-compliant to Rule 4.1.3
  int invalid3 = array[3][0]; // NON_COMPLIANT: pointer points more than one
                              // beyond the last element
}

void stack_allocated_multi_dimensional_pointer_arithmetic(int array[2][3]) {
  int valid111 = *(*(array + 0) + 0); // COMPLIANT: pointer is within boundary
  int valid112 = *(
      *(array +
        0)); // COMPLIANT: pointer is within boundary (equivalent to the above)
  int valid113 = **array; // COMPLIANT: pointer is within boundary (equivalent
                          // to the above)
  int valid121 = *(*(array + 0) + 1); // COMPLIANT: pointer is within boundary
  int valid122 =
      *(*array +
        1); // COMPLIANT: pointer is within boundary (equivalent to the above)
  int valid131 =
      *(*(array + 0) + 2); // COMPLIANT: pointer points one beyond the last
                           // element, but non-compliant to Rule 4.1.3
  int valid132 = *(
      *array +
      2); // COMPLIANT: pointer points one beyond the last
          // element, but non-compliant to Rule 4.1.3 (equivalent to the above)
  int invalid11 = *(*(array + 0) + 3); // NON_COMPLIANT: pointer points more
                                       // than one beyond the last element
  int invalid12 =
      *(*array + 3); // NON_COMPLIANT: pointer points more than
                     // one beyond the last element (equivalent to the above)

  int valid211 = *(*(array + 1) + 0); // COMPLIANT: pointer is within boundary
  int valid212 = *(
      *(array +
        1)); // COMPLIANT: pointer is within boundary (equivalent to the above)
  int valid22 = *(*(array + 1) + 1); // COMPLIANT: pointer is within boundary
  int valid23 =
      *(*(array + 1) + 2); // COMPLIANT: pointer points one beyond the last
                           // element, but non-compliant to Rule 4.1.3
  int invalid2 = *(*(array + 1) + 3); // NON_COMPLIANT: pointer points more than
                                      // one beyond the last element

  int valid311 =
      *(*(array + 2) + 0); // COMPLIANT: pointer points one beyond the last
                           // element, but non-compliant to Rule 4.1.3
  int valid312 = *(*(
      array +
      2)); // COMPLIANT: pointer points one beyond the last
           // element, but non-compliant to Rule 4.1.3 (equivalent to the above)
  int invalid31 = *(*(array + 3) + 0); // NON_COMPLIANT: pointer points more
                                       // than one beyond the last element
  int invalid32 =
      *(*(array + 3)); // NON_COMPLIANT: pointer points more than
                       // one beyond the last element (equivalent to the above)
}

/**
 * Test code that was copied from that of ARR38-C, at revision `d82ed6ee`.
 */
namespace ARR38_C_copied {
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
  char ca6_good[6] = "test1"; // ok

  wchar_t wa5_good[5] = L"test"; // ok
  wchar_t wa6_good[6] = L"test"; // ok

  // strchr
  strchr(ca5_good, 't');     // COMPLIANT
  strchr(ca5_good + 4, 't'); // COMPLIANT
  strchr(ca5_good + 5, 't'); // NON_COMPLIANT

  if (flow) {
    // strcpy from literal
    strcpy(ca5_good, "test1"); // NON_COMPLIANT
  }

  if (flow) {
    // strcpy to char buffer indirect
    strcpy(get_ca_5(), ca5_good); // COMPLIANT
    strcpy(get_ca_5(), ca6_good); // NON_COMPLIANT
  }

  // strcpy between string buffers (must be null-terminated)
  if (flow) {
    strcpy(ca5_good, ca6_good);
  } // NON_COMPLIANT
  if (flow) {
    strcpy(get_ca_5(), ca5_good);
  } // COMPLIANT
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
    strncpy(ca5_good, ca5_good, 5);
  } // COMPLIANT
  if (flow) {
    strncpy(ca5_good + 1, ca5_good + 2, 3);
  } // COMPLIANT
  if (flow) {
    strncpy(ca5_good + 1, ca5_good + 2, 2);
  } // COMPLIANT

  // wrong allocation size
  char *p1 = (char *)malloc(strlen(ca5_good) + 1);
  char *p2 = (char *)malloc(strlen(ca5_good));

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

  // strcmp
  if (flow) {
    strcmp(ca5_good, ca5_good); // COMPLIANT
    strcmp(ca5_good, ca6_good); // COMPLIANT
    strcmp(ca6_good, ca5_good); // COMPLIANT
  }
}

void test_wrong_buf_size(void) {
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
    wcsftime(wbuf, sizeof(wbuf) / sizeof(wchar_t), L"%Y-%m-%d",
             NULL); // COMPLIANT
    wcsftime(wbuf, sizeof(wbuf) / sizeof(wchar_t) + 2, L"%Y-%m-%d",
             NULL); // NON_COMPLIANT
    wcsftime(wbuf, sizeof(wbuf) / sizeof(wchar_t) - 2, L"%Y-%m-%d",
             NULL); // COMPLIANT
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

  // strncat
  {
    char buf[64];
    char buf2[64];
    strncat(buf, buf2, sizeof(buf));         // COMPLIANT
    strncat(buf, buf2, sizeof(buf) + 1);     // NON_COMPLIANT
    strncat(buf, buf2, sizeof(buf) - 1);     // COMPLIANT
    strncat(buf + 1, buf2, sizeof(buf));     // NON_COMPLIANT
    strncat(buf, buf2 + 1, sizeof(buf) * 2); // NON_COMPLIANT
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
}

void test_equivalent_expressions(void *in, int x, int y, int a, int b) {
  short *p = (short *)malloc(x * y * sizeof(short));
  memcpy(p, in, x * y * sizeof(short));     // COMPLIANT
  memcpy(p, in, x * y * sizeof(short) + 1); // NON_COMPLIANT
  memcpy(p, in, x * y * sizeof(short) - 1); // COMPLIANT
  memcpy(p, in, a * b * sizeof(short) + 1); // COMPLIANT - unknown
}
} // namespace ARR38_C_copied

int main(int argc, char *argv[]) {
  /* 1. Single-dimensional array initialized on the stack */
  int stack_single_dimensional_array[3] = {0, 1, 2};

  stack_allocated_single_dimensional_pointer_arithmetic(
      stack_single_dimensional_array);
  stack_allocated_single_dimensional_array_access(
      stack_single_dimensional_array);

  /* 2. Single-dimensional array initialized on the heap */
  int num_of_elements_malloc;
  int num_of_elements_calloc;
  int num_of_elements_realloc;

  if (argc) {
    num_of_elements_malloc = 1;
    num_of_elements_calloc = 2;
    num_of_elements_realloc = 3;
  } else {
    num_of_elements_malloc = 4;
    num_of_elements_calloc = 5;
    num_of_elements_realloc = 6;
  }

  int *single_dimensional_array_malloc =
      (int *)malloc(num_of_elements_malloc * sizeof(int));
  int *single_dimensional_array_calloc =
      (int *)calloc(num_of_elements_calloc, sizeof(int));

  int *single_dimensional_array_realloc = (int *)realloc(
      single_dimensional_array_malloc, num_of_elements_realloc * sizeof(int));

  malloc_single_dimensional_pointer_arithmetic(single_dimensional_array_malloc);
  malloc_single_dimensional_array_access(single_dimensional_array_malloc);

  calloc_single_dimensional_pointer_arithmetic(single_dimensional_array_calloc);
  calloc_single_dimensional_array_access(single_dimensional_array_calloc);

  realloc_single_dimensional_pointer_arithmetic(
      single_dimensional_array_realloc);
  realloc_single_dimensional_array_access(single_dimensional_array_realloc);

  /* 3. Multi-dimensional array initialized on the stack */
  int stack_multi_dimensional_array[2][3] = {{1, 2, 3}, {4, 5, 6}};

  /* 4. Multi-dimensional array initialized on the heap */
  int (*heap_multi_dimensional_array)[3] =
      (int (*)[3])malloc(sizeof(int[2][3]));

  stack_allocated_multi_dimensional_array_access(stack_multi_dimensional_array);
  stack_allocated_multi_dimensional_pointer_arithmetic(
      stack_multi_dimensional_array);

  return 0;
}
