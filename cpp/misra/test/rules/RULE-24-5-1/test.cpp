#include <cctype>
#include <ctype.h>
#include <cwctype>
#include <locale>
#include <wctype.h>

void test_cctype_functions() {
  char l1 = 'A';

  // Character classification functions from <cctype>
  std::isalnum(l1);  // NON_COMPLIANT
  std::isalpha(l1);  // NON_COMPLIANT
  std::isblank(l1);  // NON_COMPLIANT
  std::iscntrl(l1);  // NON_COMPLIANT
  std::isdigit(l1);  // NON_COMPLIANT
  std::isgraph(l1);  // NON_COMPLIANT
  std::islower(l1);  // NON_COMPLIANT
  std::isprint(l1);  // NON_COMPLIANT
  std::ispunct(l1);  // NON_COMPLIANT
  std::isspace(l1);  // NON_COMPLIANT
  std::isupper(l1);  // NON_COMPLIANT
  std::isxdigit(l1); // NON_COMPLIANT

  // Character case mapping functions from <cctype>
  std::tolower(l1); // NON_COMPLIANT
  std::toupper(l1); // NON_COMPLIANT
}

void test_ctype_h_functions() {
  char l1 = 'A';

  // Character classification functions from <ctype.h>
  isalnum(l1);  // NON_COMPLIANT
  isalpha(l1);  // NON_COMPLIANT
  isblank(l1);  // NON_COMPLIANT
  iscntrl(l1);  // NON_COMPLIANT
  isdigit(l1);  // NON_COMPLIANT
  isgraph(l1);  // NON_COMPLIANT
  islower(l1);  // NON_COMPLIANT
  isprint(l1);  // NON_COMPLIANT
  ispunct(l1);  // NON_COMPLIANT
  isspace(l1);  // NON_COMPLIANT
  isupper(l1);  // NON_COMPLIANT
  isxdigit(l1); // NON_COMPLIANT

  // Character case mapping functions from <ctype.h>
  tolower(l1); // NON_COMPLIANT
  toupper(l1); // NON_COMPLIANT
}

void test_cwctype_functions() {
  wchar_t l1 = L'A';

  // Wide character classification functions from <cwctype>
  std::iswalnum(l1);  // NON_COMPLIANT
  std::iswalpha(l1);  // NON_COMPLIANT
  std::iswblank(l1);  // NON_COMPLIANT
  std::iswcntrl(l1);  // NON_COMPLIANT
  std::iswdigit(l1);  // NON_COMPLIANT
  std::iswgraph(l1);  // NON_COMPLIANT
  std::iswlower(l1);  // NON_COMPLIANT
  std::iswprint(l1);  // NON_COMPLIANT
  std::iswpunct(l1);  // NON_COMPLIANT
  std::iswspace(l1);  // NON_COMPLIANT
  std::iswupper(l1);  // NON_COMPLIANT
  std::iswxdigit(l1); // NON_COMPLIANT

  // Wide character case mapping functions from <cwctype>
  std::towlower(l1); // NON_COMPLIANT
  std::towupper(l1); // NON_COMPLIANT

  // Wide character type functions from <cwctype>
  std::wctype("alpha");                        // NON_COMPLIANT
  std::iswctype(l1, std::wctype("alpha"));     // NON_COMPLIANT
  std::wctrans("tolower");                     // NON_COMPLIANT
  std::towctrans(l1, std::wctrans("tolower")); // NON_COMPLIANT
}

void test_wctype_h_functions() {
  wchar_t l1 = L'A';

  // Wide character classification functions from <wctype.h>
  iswalnum(l1);  // NON_COMPLIANT
  iswalpha(l1);  // NON_COMPLIANT
  iswblank(l1);  // NON_COMPLIANT
  iswcntrl(l1);  // NON_COMPLIANT
  iswdigit(l1);  // NON_COMPLIANT
  iswgraph(l1);  // NON_COMPLIANT
  iswlower(l1);  // NON_COMPLIANT
  iswprint(l1);  // NON_COMPLIANT
  iswpunct(l1);  // NON_COMPLIANT
  iswspace(l1);  // NON_COMPLIANT
  iswupper(l1);  // NON_COMPLIANT
  iswxdigit(l1); // NON_COMPLIANT

  // Wide character case mapping functions from <wctype.h>
  towlower(l1); // NON_COMPLIANT
  towupper(l1); // NON_COMPLIANT

  // Wide character type functions from <wctype.h>
  wctype("alpha");                   // NON_COMPLIANT
  iswctype(l1, wctype("alpha"));     // NON_COMPLIANT
  wctrans("tolower");                // NON_COMPLIANT
  towctrans(l1, wctrans("tolower")); // NON_COMPLIANT
}

void test_function_addresses() {
  // Taking addresses of functions from <cctype>
  int (*l1)(int) = &std::isalnum;   // NON_COMPLIANT
  int (*l2)(int) = &std::isalpha;   // NON_COMPLIANT
  int (*l3)(int) = &std::isblank;   // NON_COMPLIANT
  int (*l4)(int) = &std::iscntrl;   // NON_COMPLIANT
  int (*l5)(int) = &std::isdigit;   // NON_COMPLIANT
  int (*l6)(int) = &std::isgraph;   // NON_COMPLIANT
  int (*l7)(int) = &std::islower;   // NON_COMPLIANT
  int (*l8)(int) = &std::isprint;   // NON_COMPLIANT
  int (*l9)(int) = &std::ispunct;   // NON_COMPLIANT
  int (*l10)(int) = &std::isspace;  // NON_COMPLIANT
  int (*l11)(int) = &std::isupper;  // NON_COMPLIANT
  int (*l12)(int) = &std::isxdigit; // NON_COMPLIANT
  int (*l13)(int) = &std::tolower;  // NON_COMPLIANT
  int (*l14)(int) = &std::toupper;  // NON_COMPLIANT

  // Taking addresses of functions from <ctype.h>
  int (*l15)(int) = &isalnum;  // NON_COMPLIANT
  int (*l16)(int) = &isalpha;  // NON_COMPLIANT
  int (*l17)(int) = &isblank;  // NON_COMPLIANT
  int (*l18)(int) = &iscntrl;  // NON_COMPLIANT
  int (*l19)(int) = &isdigit;  // NON_COMPLIANT
  int (*l20)(int) = &isgraph;  // NON_COMPLIANT
  int (*l21)(int) = &islower;  // NON_COMPLIANT
  int (*l22)(int) = &isprint;  // NON_COMPLIANT
  int (*l23)(int) = &ispunct;  // NON_COMPLIANT
  int (*l24)(int) = &isspace;  // NON_COMPLIANT
  int (*l25)(int) = &isupper;  // NON_COMPLIANT
  int (*l26)(int) = &isxdigit; // NON_COMPLIANT
  int (*l27)(int) = &tolower;  // NON_COMPLIANT
  int (*l28)(int) = &toupper;  // NON_COMPLIANT

  // Taking addresses of functions from <cwctype>
  int (*l29)(wint_t) = &std::iswalnum;                // NON_COMPLIANT
  int (*l30)(wint_t) = &std::iswalpha;                // NON_COMPLIANT
  int (*l31)(wint_t) = &std::iswblank;                // NON_COMPLIANT
  int (*l32)(wint_t) = &std::iswcntrl;                // NON_COMPLIANT
  int (*l33)(wint_t) = &std::iswdigit;                // NON_COMPLIANT
  int (*l34)(wint_t) = &std::iswgraph;                // NON_COMPLIANT
  int (*l35)(wint_t) = &std::iswlower;                // NON_COMPLIANT
  int (*l36)(wint_t) = &std::iswprint;                // NON_COMPLIANT
  int (*l37)(wint_t) = &std::iswpunct;                // NON_COMPLIANT
  int (*l38)(wint_t) = &std::iswspace;                // NON_COMPLIANT
  int (*l39)(wint_t) = &std::iswupper;                // NON_COMPLIANT
  int (*l40)(wint_t) = &std::iswxdigit;               // NON_COMPLIANT
  wint_t (*l41)(wint_t) = &std::towlower;             // NON_COMPLIANT
  wint_t (*l42)(wint_t) = &std::towupper;             // NON_COMPLIANT
  wctype_t (*l43)(const char *) = &std::wctype;       // NON_COMPLIANT
  int (*l44)(wint_t, wctype_t) = &std::iswctype;      // NON_COMPLIANT
  wctrans_t (*l45)(const char *) = &std::wctrans;     // NON_COMPLIANT
  wint_t (*l46)(wint_t, wctrans_t) = &std::towctrans; // NON_COMPLIANT

  // Taking addresses of functions from <wctype.h>
  int (*l47)(wint_t) = &iswalnum;                // NON_COMPLIANT
  int (*l48)(wint_t) = &iswalpha;                // NON_COMPLIANT
  int (*l49)(wint_t) = &iswblank;                // NON_COMPLIANT
  int (*l50)(wint_t) = &iswcntrl;                // NON_COMPLIANT
  int (*l51)(wint_t) = &iswdigit;                // NON_COMPLIANT
  int (*l52)(wint_t) = &iswgraph;                // NON_COMPLIANT
  int (*l53)(wint_t) = &iswlower;                // NON_COMPLIANT
  int (*l54)(wint_t) = &iswprint;                // NON_COMPLIANT
  int (*l55)(wint_t) = &iswpunct;                // NON_COMPLIANT
  int (*l56)(wint_t) = &iswspace;                // NON_COMPLIANT
  int (*l57)(wint_t) = &iswupper;                // NON_COMPLIANT
  int (*l58)(wint_t) = &iswxdigit;               // NON_COMPLIANT
  wint_t (*l59)(wint_t) = &towlower;             // NON_COMPLIANT
  wint_t (*l60)(wint_t) = &towupper;             // NON_COMPLIANT
  wctype_t (*l61)(const char *) = &wctype;       // NON_COMPLIANT
  int (*l62)(wint_t, wctype_t) = &iswctype;      // NON_COMPLIANT
  wctrans_t (*l63)(const char *) = &wctrans;     // NON_COMPLIANT
  wint_t (*l64)(wint_t, wctrans_t) = &towctrans; // NON_COMPLIANT
}

void test_compliant_locale_usage() {
  char l1 = 'A';
  wchar_t l2 = L'A';
  std::locale l3{};

  // Compliant usage with locale parameter
  std::isalnum(l1, l3);  // COMPLIANT
  std::isalpha(l1, l3);  // COMPLIANT
  std::isblank(l1, l3);  // COMPLIANT
  std::iscntrl(l1, l3);  // COMPLIANT
  std::isdigit(l1, l3);  // COMPLIANT
  std::isgraph(l1, l3);  // COMPLIANT
  std::islower(l1, l3);  // COMPLIANT
  std::isprint(l1, l3);  // COMPLIANT
  std::ispunct(l1, l3);  // COMPLIANT
  std::isspace(l1, l3);  // COMPLIANT
  std::isupper(l1, l3);  // COMPLIANT
  std::isxdigit(l1, l3); // COMPLIANT

  std::tolower(l1, l3); // COMPLIANT
  std::toupper(l1, l3); // COMPLIANT

  // Compliant wide character usage with locale parameter
  std::isalnum(l2, l3);  // COMPLIANT
  std::isalpha(l2, l3);  // COMPLIANT
  std::isblank(l2, l3);  // COMPLIANT
  std::iscntrl(l2, l3);  // COMPLIANT
  std::isdigit(l2, l3);  // COMPLIANT
  std::isgraph(l2, l3);  // COMPLIANT
  std::islower(l2, l3);  // COMPLIANT
  std::isprint(l2, l3);  // COMPLIANT
  std::ispunct(l2, l3);  // COMPLIANT
  std::isspace(l2, l3);  // COMPLIANT
  std::isupper(l2, l3);  // COMPLIANT
  std::isxdigit(l2, l3); // COMPLIANT

  std::tolower(l2, l3); // COMPLIANT
  std::toupper(l2, l3); // COMPLIANT
}