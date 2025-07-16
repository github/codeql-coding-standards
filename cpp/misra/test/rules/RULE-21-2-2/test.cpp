#include <cassert>
#include <cinttypes>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cwchar>
#include <string>
#include <string_view>

void test_cstring_functions() {
  char l1[100];
  char l2[100];
  const char *l3 = "test";

  strcat(l1, l2);      // NON_COMPLIANT
  strchr(l3, 'e');     // NON_COMPLIANT
  strcmp(l1, l2);      // NON_COMPLIANT
  strcoll(l1, l2);     // NON_COMPLIANT
  strcpy(l1, l3);      // NON_COMPLIANT
  strcspn(l1, l2);     // NON_COMPLIANT
  strerror(0);         // NON_COMPLIANT
  strlen(l3);          // NON_COMPLIANT
  strncat(l1, l2, 10); // NON_COMPLIANT
  strncmp(l1, l2, 10); // NON_COMPLIANT
  strncpy(l1, l3, 10); // NON_COMPLIANT
  strpbrk(l1, l2);     // NON_COMPLIANT
  strrchr(l3, 'e');    // NON_COMPLIANT
  strspn(l1, l2);      // NON_COMPLIANT
  strstr(l1, l3);      // NON_COMPLIANT
  strtok(l1, l2);      // NON_COMPLIANT
  strxfrm(l1, l2, 50); // NON_COMPLIANT
}

void test_cstdlib_string_functions() {
  const char *l1 = "123";
  char *l2;

  strtol(l1, &l2, 10);   // NON_COMPLIANT
  strtoll(l1, &l2, 10);  // NON_COMPLIANT
  strtoul(l1, &l2, 10);  // NON_COMPLIANT
  strtoull(l1, &l2, 10); // NON_COMPLIANT
  strtod(l1, &l2);       // NON_COMPLIANT
  strtof(l1, &l2);       // NON_COMPLIANT
  strtold(l1, &l2);      // NON_COMPLIANT
}

void test_cwchar_functions() {
  wchar_t l1[100];
  const wchar_t *l2 = L"123";
  wchar_t *l3;
  FILE *l4 = nullptr;

  fgetwc(l4);            // NON_COMPLIANT
  fputwc(L'a', l4);      // NON_COMPLIANT
  wcstol(l2, &l3, 10);   // NON_COMPLIANT
  wcstoll(l2, &l3, 10);  // NON_COMPLIANT
  wcstoul(l2, &l3, 10);  // NON_COMPLIANT
  wcstoull(l2, &l3, 10); // NON_COMPLIANT
  wcstod(l2, &l3);       // NON_COMPLIANT
  wcstof(l2, &l3);       // NON_COMPLIANT
  wcstold(l2, &l3);      // NON_COMPLIANT
}

void test_cinttypes_functions() {
  const char *l1 = "123";
  char *l2;
  const wchar_t *l3 = L"123";
  wchar_t *l4;

  strtoumax(l1, &l2, 10); // NON_COMPLIANT
  strtoimax(l1, &l2, 10); // NON_COMPLIANT
  wcstoumax(l3, &l4, 10); // NON_COMPLIANT
  wcstoimax(l3, &l4, 10); // NON_COMPLIANT
}

void test_cstring_function_pointer_addresses() {
  char *(*l1)(char *, const char *) = &strcat;               // NON_COMPLIANT
  char *(*l2)(char *, const char *) = strcat;                // NON_COMPLIANT
  const char *(*l3)(const char *, int) = &strchr;            // NON_COMPLIANT
  const char *(*l4)(const char *, int) = strchr;             // NON_COMPLIANT
  int (*l5)(const char *, const char *) = &strcmp;           // NON_COMPLIANT
  int (*l6)(const char *, const char *) = strcmp;            // NON_COMPLIANT
  int (*l7)(const char *, const char *) = &strcoll;          // NON_COMPLIANT
  int (*l8)(const char *, const char *) = strcoll;           // NON_COMPLIANT
  char *(*l9)(char *, const char *) = &strcpy;               // NON_COMPLIANT
  char *(*l10)(char *, const char *) = strcpy;               // NON_COMPLIANT
  size_t (*l11)(const char *, const char *) = &strcspn;      // NON_COMPLIANT
  size_t (*l12)(const char *, const char *) = strcspn;       // NON_COMPLIANT
  char *(*l13)(int) = &strerror;                             // NON_COMPLIANT
  char *(*l14)(int) = strerror;                              // NON_COMPLIANT
  size_t (*l15)(const char *) = &strlen;                     // NON_COMPLIANT
  size_t (*l16)(const char *) = strlen;                      // NON_COMPLIANT
  char *(*l17)(char *, const char *, size_t) = &strncat;     // NON_COMPLIANT
  char *(*l18)(char *, const char *, size_t) = strncat;      // NON_COMPLIANT
  int (*l19)(const char *, const char *, size_t) = &strncmp; // NON_COMPLIANT
  int (*l20)(const char *, const char *, size_t) = strncmp;  // NON_COMPLIANT
  char *(*l21)(char *, const char *, size_t) = &strncpy;     // NON_COMPLIANT
  char *(*l22)(char *, const char *, size_t) = strncpy;      // NON_COMPLIANT
  const char *(*l23)(const char *, const char *) = &strpbrk; // NON_COMPLIANT
  const char *(*l24)(const char *, const char *) = strpbrk;  // NON_COMPLIANT
  const char *(*l25)(const char *, int) = &strrchr;          // NON_COMPLIANT
  const char *(*l26)(const char *, int) = strrchr;           // NON_COMPLIANT
  size_t (*l27)(const char *, const char *) = &strspn;       // NON_COMPLIANT
  size_t (*l28)(const char *, const char *) = strspn;        // NON_COMPLIANT
  const char *(*l29)(const char *, const char *) = &strstr;  // NON_COMPLIANT
  const char *(*l30)(const char *, const char *) = strstr;   // NON_COMPLIANT
  char *(*l31)(char *, const char *) = &strtok;              // NON_COMPLIANT
  char *(*l32)(char *, const char *) = strtok;               // NON_COMPLIANT
  size_t (*l33)(char *, const char *, size_t) = &strxfrm;    // NON_COMPLIANT
  size_t (*l34)(char *, const char *, size_t) = strxfrm;     // NON_COMPLIANT
}

void test_cstdlib_function_pointer_addresses() {
  long (*l1)(const char *, char **, int) = &strtol;           // NON_COMPLIANT
  long (*l2)(const char *, char **, int) = strtol;            // NON_COMPLIANT
  long long (*l3)(const char *, char **, int) = &strtoll;     // NON_COMPLIANT
  long long (*l4)(const char *, char **, int) = strtoll;      // NON_COMPLIANT
  unsigned long (*l5)(const char *, char **, int) = &strtoul; // NON_COMPLIANT
  unsigned long (*l6)(const char *, char **, int) = strtoul;  // NON_COMPLIANT
  unsigned long long (*l7)(const char *, char **, int) =
      &strtoull; // NON_COMPLIANT
  unsigned long long (*l8)(const char *, char **, int) =
      strtoull;                                         // NON_COMPLIANT
  double (*l9)(const char *, char **) = &strtod;        // NON_COMPLIANT
  double (*l10)(const char *, char **) = strtod;        // NON_COMPLIANT
  float (*l11)(const char *, char **) = &strtof;        // NON_COMPLIANT
  float (*l12)(const char *, char **) = strtof;         // NON_COMPLIANT
  long double (*l13)(const char *, char **) = &strtold; // NON_COMPLIANT
  long double (*l14)(const char *, char **) = strtold;  // NON_COMPLIANT
}

void test_cwchar_function_pointer_addresses() {
  wint_t (*l1)(FILE *) = &fgetwc;                               // NON_COMPLIANT
  wint_t (*l2)(FILE *) = fgetwc;                                // NON_COMPLIANT
  wint_t (*l3)(wchar_t, FILE *) = &fputwc;                      // NON_COMPLIANT
  wint_t (*l4)(wchar_t, FILE *) = fputwc;                       // NON_COMPLIANT
  long (*l5)(const wchar_t *, wchar_t **, int) = &wcstol;       // NON_COMPLIANT
  long (*l6)(const wchar_t *, wchar_t **, int) = wcstol;        // NON_COMPLIANT
  long long (*l7)(const wchar_t *, wchar_t **, int) = &wcstoll; // NON_COMPLIANT
  long long (*l8)(const wchar_t *, wchar_t **, int) = wcstoll;  // NON_COMPLIANT
  unsigned long (*l9)(const wchar_t *, wchar_t **, int) =
      &wcstoul; // NON_COMPLIANT
  unsigned long (*l10)(const wchar_t *, wchar_t **, int) =
      wcstoul; // NON_COMPLIANT
  unsigned long long (*l11)(const wchar_t *, wchar_t **, int) =
      &wcstoull; // NON_COMPLIANT
  unsigned long long (*l12)(const wchar_t *, wchar_t **, int) =
      wcstoull;                                               // NON_COMPLIANT
  double (*l13)(const wchar_t *, wchar_t **) = &wcstod;       // NON_COMPLIANT
  double (*l14)(const wchar_t *, wchar_t **) = wcstod;        // NON_COMPLIANT
  float (*l15)(const wchar_t *, wchar_t **) = &wcstof;        // NON_COMPLIANT
  float (*l16)(const wchar_t *, wchar_t **) = wcstof;         // NON_COMPLIANT
  long double (*l17)(const wchar_t *, wchar_t **) = &wcstold; // NON_COMPLIANT
  long double (*l18)(const wchar_t *, wchar_t **) = wcstold;  // NON_COMPLIANT
}

void test_cinttypes_function_pointer_addresses() {
  uintmax_t (*l1)(const char *, char **, int) = &strtoumax; // NON_COMPLIANT
  uintmax_t (*l2)(const char *, char **, int) = strtoumax;  // NON_COMPLIANT
  intmax_t (*l3)(const char *, char **, int) = &strtoimax;  // NON_COMPLIANT
  intmax_t (*l4)(const char *, char **, int) = strtoimax;   // NON_COMPLIANT
  uintmax_t (*l5)(const wchar_t *, wchar_t **, int) =
      &wcstoumax; // NON_COMPLIANT
  uintmax_t (*l6)(const wchar_t *, wchar_t **, int) =
      wcstoumax; // NON_COMPLIANT
  intmax_t (*l7)(const wchar_t *, wchar_t **, int) =
      &wcstoimax;                                               // NON_COMPLIANT
  intmax_t (*l8)(const wchar_t *, wchar_t **, int) = wcstoimax; // NON_COMPLIANT
}

void test_std_cstring_functions() {
  char l1[100];
  char l2[100];
  const char *l3 = "test";

  std::strcat(l1, l2);      // NON_COMPLIANT
  std::strchr(l3, 'e');     // NON_COMPLIANT
  std::strcmp(l1, l2);      // NON_COMPLIANT
  std::strcoll(l1, l2);     // NON_COMPLIANT
  std::strcpy(l1, l3);      // NON_COMPLIANT
  std::strcspn(l1, l2);     // NON_COMPLIANT
  std::strerror(0);         // NON_COMPLIANT
  std::strlen(l3);          // NON_COMPLIANT
  std::strncat(l1, l2, 10); // NON_COMPLIANT
  std::strncmp(l1, l2, 10); // NON_COMPLIANT
  std::strncpy(l1, l3, 10); // NON_COMPLIANT
  std::strpbrk(l1, l2);     // NON_COMPLIANT
  std::strrchr(l3, 'e');    // NON_COMPLIANT
  std::strspn(l1, l2);      // NON_COMPLIANT
  std::strstr(l1, l3);      // NON_COMPLIANT
  std::strtok(l1, l2);      // NON_COMPLIANT
  std::strxfrm(l1, l2, 50); // NON_COMPLIANT
}

void test_std_cstdlib_string_functions() {
  const char *l1 = "123";
  char *l2;

  std::strtol(l1, &l2, 10);   // NON_COMPLIANT
  std::strtoll(l1, &l2, 10);  // NON_COMPLIANT
  std::strtoul(l1, &l2, 10);  // NON_COMPLIANT
  std::strtoull(l1, &l2, 10); // NON_COMPLIANT
  std::strtod(l1, &l2);       // NON_COMPLIANT
  std::strtof(l1, &l2);       // NON_COMPLIANT
  std::strtold(l1, &l2);      // NON_COMPLIANT
}

void test_std_cwchar_functions() {
  wchar_t l1[100];
  const wchar_t *l2 = L"123";
  wchar_t *l3;
  FILE *l4 = nullptr;

  std::fgetwc(l4);            // NON_COMPLIANT
  std::fputwc(L'a', l4);      // NON_COMPLIANT
  std::wcstol(l2, &l3, 10);   // NON_COMPLIANT
  std::wcstoll(l2, &l3, 10);  // NON_COMPLIANT
  std::wcstoul(l2, &l3, 10);  // NON_COMPLIANT
  std::wcstoull(l2, &l3, 10); // NON_COMPLIANT
  std::wcstod(l2, &l3);       // NON_COMPLIANT
  std::wcstof(l2, &l3);       // NON_COMPLIANT
  std::wcstold(l2, &l3);      // NON_COMPLIANT
}

void test_std_cinttypes_functions() {
  const char *l1 = "123";
  char *l2;
  const wchar_t *l3 = L"123";
  wchar_t *l4;

  std::strtoumax(l1, &l2, 10); // NON_COMPLIANT
  std::strtoimax(l1, &l2, 10); // NON_COMPLIANT
  std::wcstoumax(l3, &l4, 10); // NON_COMPLIANT
  std::wcstoimax(l3, &l4, 10); // NON_COMPLIANT
}

void test_std_cstring_function_pointer_addresses() {
  char *(*l1)(char *, const char *) = &std::strcat;           // NON_COMPLIANT
  char *(*l2)(char *, const char *) = std::strcat;            // NON_COMPLIANT
  const char *(*l3)(const char *, int) = &std::strchr;        // NON_COMPLIANT
  const char *(*l4)(const char *, int) = std::strchr;         // NON_COMPLIANT
  int (*l5)(const char *, const char *) = &std::strcmp;       // NON_COMPLIANT
  int (*l6)(const char *, const char *) = std::strcmp;        // NON_COMPLIANT
  int (*l7)(const char *, const char *) = &std::strcoll;      // NON_COMPLIANT
  int (*l8)(const char *, const char *) = std::strcoll;       // NON_COMPLIANT
  char *(*l9)(char *, const char *) = &std::strcpy;           // NON_COMPLIANT
  char *(*l10)(char *, const char *) = std::strcpy;           // NON_COMPLIANT
  size_t (*l11)(const char *, const char *) = &std::strcspn;  // NON_COMPLIANT
  size_t (*l12)(const char *, const char *) = std::strcspn;   // NON_COMPLIANT
  char *(*l13)(int) = &std::strerror;                         // NON_COMPLIANT
  char *(*l14)(int) = std::strerror;                          // NON_COMPLIANT
  size_t (*l15)(const char *) = &std::strlen;                 // NON_COMPLIANT
  size_t (*l16)(const char *) = std::strlen;                  // NON_COMPLIANT
  char *(*l17)(char *, const char *, size_t) = &std::strncat; // NON_COMPLIANT
  char *(*l18)(char *, const char *, size_t) = std::strncat;  // NON_COMPLIANT
  int (*l19)(const char *, const char *, size_t) =
      &std::strncmp; // NON_COMPLIANT
  int (*l20)(const char *, const char *, size_t) =
      std::strncmp;                                           // NON_COMPLIANT
  char *(*l21)(char *, const char *, size_t) = &std::strncpy; // NON_COMPLIANT
  char *(*l22)(char *, const char *, size_t) = std::strncpy;  // NON_COMPLIANT
  const char *(*l23)(const char *, const char *) =
      &std::strpbrk; // NON_COMPLIANT
  const char *(*l24)(const char *, const char *) =
      std::strpbrk;                                         // NON_COMPLIANT
  const char *(*l25)(const char *, int) = &std::strrchr;    // NON_COMPLIANT
  const char *(*l26)(const char *, int) = std::strrchr;     // NON_COMPLIANT
  size_t (*l27)(const char *, const char *) = &std::strspn; // NON_COMPLIANT
  size_t (*l28)(const char *, const char *) = std::strspn;  // NON_COMPLIANT
  const char *(*l29)(const char *, const char *) =
      &std::strstr;                                             // NON_COMPLIANT
  const char *(*l30)(const char *, const char *) = std::strstr; // NON_COMPLIANT
  char *(*l31)(char *, const char *) = &std::strtok;            // NON_COMPLIANT
  char *(*l32)(char *, const char *) = std::strtok;             // NON_COMPLIANT
  size_t (*l33)(char *, const char *, size_t) = &std::strxfrm;  // NON_COMPLIANT
  size_t (*l34)(char *, const char *, size_t) = std::strxfrm;   // NON_COMPLIANT
}

void test_std_cstdlib_function_pointer_addresses() {
  long (*l1)(const char *, char **, int) = &std::strtol;       // NON_COMPLIANT
  long (*l2)(const char *, char **, int) = std::strtol;        // NON_COMPLIANT
  long long (*l3)(const char *, char **, int) = &std::strtoll; // NON_COMPLIANT
  long long (*l4)(const char *, char **, int) = std::strtoll;  // NON_COMPLIANT
  unsigned long (*l5)(const char *, char **, int) =
      &std::strtoul; // NON_COMPLIANT
  unsigned long (*l6)(const char *, char **, int) =
      std::strtoul; // NON_COMPLIANT
  unsigned long long (*l7)(const char *, char **, int) =
      &std::strtoull; // NON_COMPLIANT
  unsigned long long (*l8)(const char *, char **, int) =
      std::strtoull;                                         // NON_COMPLIANT
  double (*l9)(const char *, char **) = &std::strtod;        // NON_COMPLIANT
  double (*l10)(const char *, char **) = std::strtod;        // NON_COMPLIANT
  float (*l11)(const char *, char **) = &std::strtof;        // NON_COMPLIANT
  float (*l12)(const char *, char **) = std::strtof;         // NON_COMPLIANT
  long double (*l13)(const char *, char **) = &std::strtold; // NON_COMPLIANT
  long double (*l14)(const char *, char **) = std::strtold;  // NON_COMPLIANT
}

void test_std_cwchar_function_pointer_addresses() {
  wint_t (*l1)(FILE *) = &std::fgetwc;                         // NON_COMPLIANT
  wint_t (*l2)(FILE *) = std::fgetwc;                          // NON_COMPLIANT
  wint_t (*l3)(wchar_t, FILE *) = &std::fputwc;                // NON_COMPLIANT
  wint_t (*l4)(wchar_t, FILE *) = std::fputwc;                 // NON_COMPLIANT
  long (*l5)(const wchar_t *, wchar_t **, int) = &std::wcstol; // NON_COMPLIANT
  long (*l6)(const wchar_t *, wchar_t **, int) = std::wcstol;  // NON_COMPLIANT
  long long (*l7)(const wchar_t *, wchar_t **, int) =
      &std::wcstoll; // NON_COMPLIANT
  long long (*l8)(const wchar_t *, wchar_t **, int) =
      std::wcstoll; // NON_COMPLIANT
  unsigned long (*l9)(const wchar_t *, wchar_t **, int) =
      &std::wcstoul; // NON_COMPLIANT
  unsigned long (*l10)(const wchar_t *, wchar_t **, int) =
      std::wcstoul; // NON_COMPLIANT
  unsigned long long (*l11)(const wchar_t *, wchar_t **, int) =
      &std::wcstoull; // NON_COMPLIANT
  unsigned long long (*l12)(const wchar_t *, wchar_t **, int) =
      std::wcstoull;                                         // NON_COMPLIANT
  double (*l13)(const wchar_t *, wchar_t **) = &std::wcstod; // NON_COMPLIANT
  double (*l14)(const wchar_t *, wchar_t **) = std::wcstod;  // NON_COMPLIANT
  float (*l15)(const wchar_t *, wchar_t **) = &std::wcstof;  // NON_COMPLIANT
  float (*l16)(const wchar_t *, wchar_t **) = std::wcstof;   // NON_COMPLIANT
  long double (*l17)(const wchar_t *, wchar_t **) =
      &std::wcstold; // NON_COMPLIANT
  long double (*l18)(const wchar_t *, wchar_t **) =
      std::wcstold; // NON_COMPLIANT
}

void test_std_cinttypes_function_pointer_addresses() {
  uintmax_t (*l1)(const char *, char **, int) =
      &std::strtoumax;                                          // NON_COMPLIANT
  uintmax_t (*l2)(const char *, char **, int) = std::strtoumax; // NON_COMPLIANT
  intmax_t (*l3)(const char *, char **, int) = &std::strtoimax; // NON_COMPLIANT
  intmax_t (*l4)(const char *, char **, int) = std::strtoimax;  // NON_COMPLIANT
  uintmax_t (*l5)(const wchar_t *, wchar_t **, int) =
      &std::wcstoumax; // NON_COMPLIANT
  uintmax_t (*l6)(const wchar_t *, wchar_t **, int) =
      std::wcstoumax; // NON_COMPLIANT
  intmax_t (*l7)(const wchar_t *, wchar_t **, int) =
      &std::wcstoimax; // NON_COMPLIANT
  intmax_t (*l8)(const wchar_t *, wchar_t **, int) =
      std::wcstoimax; // NON_COMPLIANT
}

void test_compliant_alternatives() {
  char l1[100];
  const char *l2 = "test";
  std::size_t l3 = 50;

  // Using std::string_view instead of strlen
  std::string_view l4 = l2;
  if (l4.size() + 1u < l3) { // COMPLIANT
    l4.copy(l1, l4.size());  // COMPLIANT
    l1[l4.size()] = 0;       // COMPLIANT
  }

  // Using std::string for string operations
  std::string l5 = "hello";
  std::string l6 = "world";
  std::string l7 = l5 + l6; // COMPLIANT

  // Using standard library numeric conversions
  std::string l8 = "123";
  std::int32_t l9 = std::stoi(l8); // COMPLIANT
  double l10 = std::stod(l8);      // COMPLIANT
}