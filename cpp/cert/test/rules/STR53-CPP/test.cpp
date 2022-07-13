#include <string>

int get_index();

void test_string() {
  std::string s("adsvsdfdsf");
  s[get_index()] = '1'; // NON_COMPLIANT

  s[0];  // COMPLIANT
  s[9];  // COMPLIANT
  s[10]; // NON_COMPLIANT
  s[11]; // NON_COMPLIANT
}

void test_range_check(std::string &s) {
  if (s.size() > 2) {
    s[0]; // COMPLIANT
    s[1]; // COMPLIANT
    s[2]; // COMPLIANT
    s[3]; // NON_COMPLIANT
  } else {
    s[0]; // NON_COMPLIANT
    s[1]; // NON_COMPLIANT
    s[2]; // NON_COMPLIANT
    s[3]; // NON_COMPLIANT
  }
}

void test_different_constructors(char *buffer) {
  std::string s;
  s[0]; // NON_COMPLIANT - s is empty

  // Creates a string of exactly size 2 based on buffer
  std::string s2(buffer, 2);
  s2[0]; // COMPLIANT
  s2[1]; // COMPLIANT
  s2[2]; // NON_COMPLIANT

  std::string s3(2, ' ');
  s3[0]; // COMPLIANT
  s3[1]; // COMPLIANT
  s3[2]; // NON_COMPLIANT
}