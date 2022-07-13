#include <cctype>

void test_used_with_signed_int(int x) {
  std::isalnum(x);  // NON_COMPLIANT
  std::isalpha(x);  // NON_COMPLIANT
  std::iscntrl(x);  // NON_COMPLIANT
  std::isdigit(x);  // NON_COMPLIANT
  std::islower(x);  // NON_COMPLIANT
  std::isgraph(x);  // NON_COMPLIANT
  std::isprint(x);  // NON_COMPLIANT
  std::ispunct(x);  // NON_COMPLIANT
  std::isspace(x);  // NON_COMPLIANT
  std::isupper(x);  // NON_COMPLIANT
  std::isxdigit(x); // NON_COMPLIANT
  std::tolower(x);  // NON_COMPLIANT
  std::toupper(x);  // NON_COMPLIANT
}

void test_used_with_unsigned_char(unsigned char x) {
  std::isalnum(x);  // COMPLIANT
  std::isalpha(x);  // COMPLIANT
  std::iscntrl(x);  // COMPLIANT
  std::isdigit(x);  // COMPLIANT
  std::islower(x);  // COMPLIANT
  std::isgraph(x);  // COMPLIANT
  std::isprint(x);  // COMPLIANT
  std::ispunct(x);  // COMPLIANT
  std::isspace(x);  // COMPLIANT
  std::isupper(x);  // COMPLIANT
  std::isxdigit(x); // COMPLIANT
  std::tolower(x);  // COMPLIANT
  std::toupper(x);  // COMPLIANT
}

void test_used_with_cast(int x) {
  std::isalnum((unsigned char)x);  // COMPLIANT
  std::isalpha((unsigned char)x);  // COMPLIANT
  std::iscntrl((unsigned char)x);  // COMPLIANT
  std::isdigit((unsigned char)x);  // COMPLIANT
  std::islower((unsigned char)x);  // COMPLIANT
  std::isgraph((unsigned char)x);  // COMPLIANT
  std::isprint((unsigned char)x);  // COMPLIANT
  std::ispunct((unsigned char)x);  // COMPLIANT
  std::isspace((unsigned char)x);  // COMPLIANT
  std::isupper((unsigned char)x);  // COMPLIANT
  std::isxdigit((unsigned char)x); // COMPLIANT
  std::tolower((unsigned char)x);  // COMPLIANT
  std::toupper((unsigned char)x);  // COMPLIANT
}

void test_used_with_static_cast(int x) {
  std::isalnum(static_cast<unsigned char>(x));  // COMPLIANT
  std::isalpha(static_cast<unsigned char>(x));  // COMPLIANT
  std::iscntrl(static_cast<unsigned char>(x));  // COMPLIANT
  std::isdigit(static_cast<unsigned char>(x));  // COMPLIANT
  std::islower(static_cast<unsigned char>(x));  // COMPLIANT
  std::isgraph(static_cast<unsigned char>(x));  // COMPLIANT
  std::isprint(static_cast<unsigned char>(x));  // COMPLIANT
  std::ispunct(static_cast<unsigned char>(x));  // COMPLIANT
  std::isspace(static_cast<unsigned char>(x));  // COMPLIANT
  std::isupper(static_cast<unsigned char>(x));  // COMPLIANT
  std::isxdigit(static_cast<unsigned char>(x)); // COMPLIANT
  std::tolower(static_cast<unsigned char>(x));  // COMPLIANT
  std::toupper(static_cast<unsigned char>(x));  // COMPLIANT
}