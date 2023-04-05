#include <stdio.h>
#include <wchar.h>

void sample1() {
  /* Test for plain char type */
  const char *s1 =
      "string1"; // COMPLIANT: string literal assigned to a const char* variable
  const register volatile char *s2 =
      "string2";        // COMPLIANT: string literal assigned to a const char*
                        // variable, don't care about the qualifiers
  char *s3 = "string3"; // NON_COMPLIANT: char* variable declared to hold a
                        // string literal
  s3 =
      "string4"; // NON_COMPLIANT: char* variable assigned a string literal
                 // (not likely to be seen in production, since there is strcpy)

  /* Test for wide char type */
  const wchar_t *ws1 = L"wide string1"; // COMPLIANT: string literal assigned to
                                        // a const char* variable
  const register volatile wchar_t *ws2 =
      L"wide string2"; // COMPLIANT: string literal assigned to a const char*
                       // variable, don't care about the qualifiers
  wchar_t *ws3 = L"wide string3"; // NON_COMPLIANT: char* variable declared to
                                  // hold a string literal
  ws3 = L"wide string4"; // NON_COMPLIANT: char* variable assigned a string
                         // literal (not likely to be seen in production, since
                         // there is strcpy)
}

/* Testing returning a plain string literal */
const char *sample2(int x) {
  if (x == 1)
    return "string5"; // COMPLIANT: can return a string literal with return type
                      // being const char* being const char*
  else
    return NULL;
}

/* Testing returning a wide string literal */
const wchar_t *w_sample2(int x) {
  if (x == 1)
    return L"string5"; // COMPLIANT: can return a string literal with return
                       // type being const char* being const char*
  else
    return NULL;
}

char *sample3(int x) {
  if (x == 1)
    return "string6"; // NON_COMPLIANT: can return a string literal with return
                      // type being char*
  else
    return NULL;
}

wchar_t *w_sample3(int x) {
  if (x == 1)
    return L"string6"; // NON_COMPLIANT: can return a string literal with return
                       // type being char*
  else
    return NULL;
}

void sample4(char *string) {}

void sample5(const char *string) {}

void call45() {
  sample4("string8"); // NON_COMPLIANT: can't pass string literal to char*
  sample5("string9"); // COMPLIANT: passing string literal to const char*
}

void w_sample4(wchar_t *string) {}

void w_sample5(const wchar_t *string) {}

void w_call45() {
  w_sample4(L"string8"); // NON_COMPLIANT: can't pass string literal to char*
  w_sample5(L"string9"); // COMPLIANT: passing string literal to const char*
}

int main() { return 0; }
