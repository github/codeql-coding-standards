#include <strstream>

void test_strstreambuf() {
  std::strstreambuf x; // NON_COMPLIANT
}

std::strstreambuf *f1() { // NON_COMPLIANT
  return new std::strstreambuf();
}

void test_istrstream() {
  std::istrstream i1("foo"); // NON_COMPLIANT
  char *s = "foo";
  std::istrstream i2(s); // NON_COMPLIANT
  char arr[] = {'4', ' ', '5', ' ', '6'};
  std::istrstream i3(arr, sizeof arr); // NON_COMPLIANT
}

std::istrstream *f2(char *s) { // NON_COMPLIANT
  return new std::istrstream(s);
}

void test_ostrstream() {
  std::ostrstream o; // NON_COMPLIANT
}

std::ostrstream *f3() { // NON_COMPLIANT
  return new std::ostrstream();
}