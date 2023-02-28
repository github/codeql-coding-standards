#include <stdio.h>

void sample1() {
  const char *s1 =
      "string"; // COMPLIANT: string literal assigned to a const char* variable
  const register volatile char *s2 =
      "string"; // COMPLIANT: string literal assigned to a const char* variable,
                // don't care about the qualifiers
  char *s3 =
      "string"; // NON_COMPLIANT: string literal assigned to a char* variable
  s2 = s3;      // COMPLIANT: string literal assigned to a char* variable
  s3 = s2;      // NON_COMPLIANT: string literal assigned to a char* variable
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

const char *sample6(int x) {
  const char *result;
  if (x == 1)
    result = "string"; // COMPLIANT: string literal assigned to a const char*
                       // variable
  else
    result = NULL;

  return result; // COMPLIANT: `result` can be a string literal with return type
                 // being const char*
}

void sample4(char *string) {}

void sample5(const char *string) {}

void call45() {
  const char *literal = "string";
  sample4(literal);  // NON_COMPLIANT: can't pass string literal to char*
  sample4("string"); // NON_COMPLIANT: can't pass string literal to char*
  sample5(literal);  // COMPLIANT: passing string literal to const char*
  sample5("string"); // COMPLIANT: passing string literal to const char*
}

int main() { return 0; }