#ifndef _GHLIBCPP_LOCALE
#define _GHLIBCPP_LOCALE

struct lconv;
char *setlocale(int, const char *);
lconv *localeconv();

#endif // _GHLIBCPP_LOCALE