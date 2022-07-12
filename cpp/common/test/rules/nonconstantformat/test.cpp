#include <cstdint>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <string>
void F1(const char *input) {
  static const char format[] = "IN: %s .";
  size_t len = std::strlen(input) + sizeof(format);
  char *msg = new char[len];
  int ret = snprintf(msg, len, format, input);
  fprintf(stderr, msg); // NON_COMPLIANT
  delete[] msg;
}
void F2(const char *input) {
  static const char format[] = "IN: %s .";
  fprintf(stderr, format, input); // COMPLIANT
}
void F3(const std::string &input) {
  std::cerr << "IN: " << input; // COMPLIANT
}
