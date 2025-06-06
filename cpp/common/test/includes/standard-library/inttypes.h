#ifndef _GHLIBCPP_INTTYPES
#define _GHLIBCPP_INTTYPES
#include <stdint.h>

// String conversion functions
intmax_t strtoimax(const char *str, char **endptr, int base);
uintmax_t strtoumax(const char *str, char **endptr, int base);

// Wide character versions
intmax_t wcstoimax(const wchar_t *str, wchar_t **endptr, int base);
uintmax_t wcstoumax(const wchar_t *str, wchar_t **endptr, int base);
#endif // _GHLIBCPP_INTTYPES