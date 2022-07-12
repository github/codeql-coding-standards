//% $Id: A18-5-9.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <new>
void *operator new(std::size_t count, const std::nothrow_t &tag) {
  extern void *custom_alloc(std::size_t); // Implemented elsewhere; may return
  nullptr if (void *ret = custom_alloc(count)) { return ret; }
  throw std::bad_alloc(); // non-compliant, this version of new method shall not
                          // throw exceptions
}
