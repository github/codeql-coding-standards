//% $Id: A3-1-6.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <cstdint>

class A {
public:
  A(std::int32_t l) noexcept : limit{l} {}
  // compliant
  std::int32_t Limit() const noexcept { return limit; }
  // compliant
  void SetLimit(std::int32_t l) { limit = l; }

  // non-compliant
  // std::int32_t Limit() const noexcept
  //{
  // open file, read data, close file
  // return value
  //}
  // non-compliant
  // void SetLimit(std::int32_t l)
  //{
  // open file, write data, close file
  //}
private:
  std::int32_t limit;
};