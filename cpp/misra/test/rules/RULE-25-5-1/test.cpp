#include <cctype>
#include <clocale>
#include <locale>

void test_setlocale_call() {
  std::setlocale(LC_ALL, "C");            // NON_COMPLIANT
  std::setlocale(LC_NUMERIC, "C");        // NON_COMPLIANT
  std::setlocale(LC_TIME, "en_US.UTF-8"); // NON_COMPLIANT
}

void test_locale_global_call() {
  std::locale::global(std::locale("C"));       // NON_COMPLIANT
  std::locale::global(std::locale::classic()); // NON_COMPLIANT
}

void test_compliant_locale_usage() {
  wchar_t l1 = L'\u2002';
  std::locale l2("C");

  if (std::isspace(l1, l2)) { // COMPLIANT
  }
  if (std::isalpha(l1, l2)) { // COMPLIANT
  }
  if (std::isdigit(l1, l2)) { // COMPLIANT
  }
}

void test_compliant_locale_construction() {
  std::locale l3("C");                     // COMPLIANT
  std::locale l4 = std::locale::classic(); // COMPLIANT
  std::locale l5;                          // COMPLIANT
}

void test_nested_setlocale_calls() {
  if (true) {
    std::setlocale(LC_ALL, "ja_JP.utf8"); // NON_COMPLIANT
  }

  for (int l6 = 0; l6 < 1; ++l6) {
    std::setlocale(LC_CTYPE, "C"); // NON_COMPLIANT
  }
}

void test_locale_global_with_different_locales() {
  std::locale::global(std::locale("en_US.UTF-8")); // NON_COMPLIANT
  std::locale::global(std::locale("ja_JP.utf8"));  // NON_COMPLIANT
}