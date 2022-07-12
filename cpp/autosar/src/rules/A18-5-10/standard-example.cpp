//% $Id: A18-5-10.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <cstdint>
#include <new>
void Foo() {
  uint8_t c;
  uint64_t *ptr = ::new (&c) uint64_t;
  // non-compliant, insufficient storage
}
void Bar() {
  uint8_t c; // Used elsewhere in the function
  uint8_t buf[sizeof(uint64_t)];
  uint64_t *ptr = ::new (buf) uint64_t;
  // non-compliant, storage not properly aligned
}