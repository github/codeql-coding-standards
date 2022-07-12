#include <clocale>

void test_std_setocale_is_used() {
  std::setlocale(LC_ALL, "en_US.UTF-8");      // NON_COMPLIANT
  std::setlocale(LC_COLLATE, "en_US.UTF-8");  // NON_COMPLIANT
  std::setlocale(LC_CTYPE, "en_US.UTF-8");    // NON_COMPLIANT
  std::setlocale(LC_MONETARY, "en_US.UTF-8"); // NON_COMPLIANT
  std::setlocale(LC_NUMERIC, "en_US.UTF-8");  // NON_COMPLIANT
  std::setlocale(LC_TIME, "en_US.UTF-8");     // NON_COMPLIANT
  std::lconv *lc = std::localeconv();         // NON_COMPLIANT

  setlocale(LC_ALL, "en_US.UTF-8");      // NON_COMPLIANT
  setlocale(LC_COLLATE, "en_US.UTF-8");  // NON_COMPLIANT
  setlocale(LC_CTYPE, "en_US.UTF-8");    // NON_COMPLIANT
  setlocale(LC_MONETARY, "en_US.UTF-8"); // NON_COMPLIANT
  setlocale(LC_NUMERIC, "en_US.UTF-8");  // NON_COMPLIANT
  setlocale(LC_TIME, "en_US.UTF-8");     // NON_COMPLIANT
  lconv *lc1 = localeconv();             // NON_COMPLIANT
}