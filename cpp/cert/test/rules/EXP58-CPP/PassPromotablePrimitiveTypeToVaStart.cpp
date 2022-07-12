#include <cinttypes>
#include <cstdarg>

void f(float count, ...) {
  std::va_list args;
  va_start(args, count); // NON_COMPLIANT
  va_end(args);
}

void g(unsigned short count, ...) {
  std::va_list args;
  va_start(args, count); // NON_COMPLIANT
  va_end(args);
}

void h(uint8_t count, ...) {
  std::va_list args;
  va_start(args, count); // NON_COMPLIANT
  va_end(args);
}

void i(int count, ...) {
  std::va_list args;
  va_start(args, count); // COMPLIANT
  va_end(args);
}

void j(uint32_t count, ...) {
  std::va_list args;
  va_start(args, count); // COMPLIANT
  va_end(args);
}

void k(double count, ...) {
  std::va_list args;
  va_start(args, count); // COMPLIANT
  va_end(args);
}
