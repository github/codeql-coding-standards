// $Id: A13-2-2.cpp 271687 2017-03-23 08:57:35Z piotr.tanski $
#include <cstdint>
class A
{
};

A operator+(A const&, A const&) noexcept // Compliant
{
  return A{};
}
std::int32_t operator/(A const&, A const&) noexcept // Compliant
{
  return 0;
}
A operator&(A const&, A const&)noexcept // Compliant
{
  return A{};
}
const A operator-(A const&, std::int32_t) noexcept // Non-compliant 
{
  return A{};
}
A* operator|(A const&, A const&) noexcept // Non-compliant 
{
  return new A{};
}