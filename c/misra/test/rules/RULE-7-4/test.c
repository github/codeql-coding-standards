#include <stdio.h>

void sample1() {
  const char *s1 =
      "string"; // COMPLIANT: string literal assigned to a const char* variable
  const register volatile char *s2 =
      "string"; // COMPLIANT: string literal assigned to a const char* variable,
                // don't care about the qualifiers
  char *s3 = "string"; // NON_COMPLIANT: char* variable declared to hold a
                       // string literal
}

const char *sample2(int x) {
  if (x == 1)
    return "string"; // COMPLIANT: can return a string literal with return type
                     // being const char* being const char*
  else
    return NULL;
}

char *sample3(int x) {
  if (x == 1)
    return "string"; // NON_COMPLIANT: can return a string literal with return
                     // type being char*
  else
    return NULL;
}

void sample4(char *string) {}

void sample5(const char *string) {}

void call45() {
  const char *literal = "string";
  sample4("string"); // NON_COMPLIANT: can't pass string literal to char*
  sample5("string"); // COMPLIANT: passing string literal to const char*
}

int main() { return 0; }