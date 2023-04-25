#include <string.h>

void sample() {
  int from1 = 1000000;
  char to1;
  memcpy(&from1, &to1, 1); // NON_COMPLIANT, the types are not compatible

  int from2 = 1000000;
  int to2;
  memcpy(&from2, &to2, 2); // COMPLIANT

  char from3[] = "string";
  char to3[7];
  memmove(from3, to3, 7); // COMPLIANT

  char from4[] = "sstringg";
  int to4[2];
  memmove(from4, to4, 8); // NON_COMPLIANT, despite being equal in byte counts

  char from5[] = "STRING";
  char to5[] = "string";
  memcmp(from5, to5, 2); // COMPLIANT
}

int main() { return 0; }