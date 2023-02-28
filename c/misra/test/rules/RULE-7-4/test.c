#include <stdio.h>

void sample1() {
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
}

const char *sample2(int x) {
  if (x == 1)
    return "string5"; // COMPLIANT: can return a string literal with return type
                      // being const char* being const char*
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

void sample4(char *string) {}

void sample5(const char *string) {}

void call45() {
  const char *literal = "string7";
  sample4("string8"); // NON_COMPLIANT: can't pass string literal to char*
  sample5("string9"); // COMPLIANT: passing string literal to const char*
}

int main() { return 0; }