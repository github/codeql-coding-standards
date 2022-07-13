//% $Id: A0-4-1.cpp 271389 2017-03-21 14:41:05Z piotr.tanski $
#include <limits> 
static_assert(
  std::numeric_limits<float>::is_iec559,
  "Type float does not comply with IEEE 754 single precision format"); 
static_assert(
  std::numeric_limits<float>::digits == 24,
  "Type float does not comply with IEEE 754 single precision format");
static_assert(
  std::numeric_limits<double>::is_iec559,
  "type double does not comply with IEEE 754 double precision format");
static_assert(
  std::numeric_limits<double>::digits == 53,
  "Type double does not comply with IEEE 754 double precision format");