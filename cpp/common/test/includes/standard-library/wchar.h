#ifndef _GHLIBCPP_WCHAR
#define _GHLIBCPP_WCHAR

#include "stddef.h"
#include "wctype.h"

// Wide character I/O functions
wint_t fgetwc(void *stream);
wint_t fputwc(wchar_t wc, void *stream);

// Wide character string conversion functions
long wcstol(const wchar_t *str, wchar_t **endptr, int base);
long long wcstoll(const wchar_t *str, wchar_t **endptr, int base);
unsigned long wcstoul(const wchar_t *str, wchar_t **endptr, int base);
unsigned long long wcstoull(const wchar_t *str, wchar_t **endptr, int base);
double wcstod(const wchar_t *str, wchar_t **endptr);
float wcstof(const wchar_t *str, wchar_t **endptr);
long double wcstold(const wchar_t *str, wchar_t **endptr);

// Character classification and conversion types
typedef struct {
  int __count;
  union {
    unsigned int __wch;
    char __wchb[4];
  } __value;
} mbstate_t;

#endif // _GHLIBCPP_WCHAR