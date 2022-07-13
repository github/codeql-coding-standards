#include <string>

void test_loop_skips_condition() {
  for (int i = 0; i != 10; i += 3) // NON_COMPLIANT
    ;
  for (int i = 10; i != 0; i -= 3) // NON_COMPLIANT
    ;
}

void test_loop_does_not_skip_condition() {
  for (int i = 0; i != 10; i++) // COMPLIANT
    ;
  for (int i = 0; i <= 10; i++) // COMPLIANT
    ;
  for (int i = 0; i <= 10; i += 2) // COMPLIANT
    ;
}

void test_iterator() {
  std::string s = "A string";
  for (std::string::iterator it = s.begin(); it != s.end(); ++it) // COMPLIANT
    ;

  for (std::string::iterator it = s.begin(); it != s.end();
       it += 2) // NON_COMPLIANT
    ;
}