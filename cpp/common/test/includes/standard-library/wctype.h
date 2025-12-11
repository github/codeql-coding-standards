#ifndef _GHLIBCPP_WCTYPE
#define _GHLIBCPP_WCTYPE

typedef long wint_t;
typedef long wctype_t;
typedef long wctrans_t;

// Wide character classification functions
extern int iswalnum(wint_t wc);
extern int iswalpha(wint_t wc);
extern int iswblank(wint_t wc);
extern int iswcntrl(wint_t wc);
extern int iswdigit(wint_t wc);
extern int iswgraph(wint_t wc);
extern int iswlower(wint_t wc);
extern int iswprint(wint_t wc);
extern int iswpunct(wint_t wc);
extern int iswspace(wint_t wc);
extern int iswupper(wint_t wc);
extern int iswxdigit(wint_t wc);

// Wide character conversion functions
extern wint_t towlower(wint_t wc);
extern wint_t towupper(wint_t wc);

// Generic wide character classification functions
extern int iswctype(wint_t wc, wctype_t desc);
extern wctype_t wctype(const char *property);

// Generic wide character mapping functions
extern wint_t towctrans(wint_t wc, wctrans_t desc);
extern wctrans_t wctrans(const char *property);

// Wide character constants
static const wint_t WEOF = static_cast<wint_t>(-1);

#endif // _GHLIBCPP_WCTYPE