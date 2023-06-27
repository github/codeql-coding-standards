#include <string>

void f1(const char *p1) {

  std::string s = "CodeQL";

  const char *a1 = "CodeQL";  // NON_COMPLIANT
  const char *a2 = s.c_str(); // NON_COMPLIANT
  char *a3;

  const char a4[] = {1, 2, 3, 4};
  char *a5;

  a3[0] = 'a';

  a3 = (char *)a1;

  a3 = (char *)p1;
}

void f2() {
  std::string s = "CodeQL";
  const char *a1 = "CodeQL"; // NON_COMPLIANT
  char a2[] = {1, 2, 3};

  f1(a1);
  f1(a2);
  f1(s.c_str()); // NON_COMPLIANT
  __func__;
}