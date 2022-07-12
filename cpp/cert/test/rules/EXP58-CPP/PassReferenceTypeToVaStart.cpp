#include <cstdarg>

void f(int &count, ...) {
  std::va_list args;
  va_start(args, count); // NON_COMPLIANT
  va_end(args);
}

void g(int *count, ...) {
  std::va_list args;
  va_start(args, count); // COMPLIANT
  va_end(args);
}