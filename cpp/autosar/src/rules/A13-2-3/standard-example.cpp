// $Id: A13-2-3.cpp 271687 2017-03-23 08:57:35Z piotr.tanski $
#include <cstdint> 
class A
{
};

bool operator==(A const&, A const&) noexcept // Compliant
{
  return true;
}
bool operator<(A const&, A const&) noexcept // Compliant
{
  return false;
}
bool operator!=(A const& lhs, A const& rhs) noexcept // Compliant
{
  return !(operator==(lhs, rhs));
}
std::int32_t operator>(A const&, A const&) noexcept // Non-compliant
{
  return -1;
}
A operator>=(A const&, A const&) noexcept // Non-compliant
{
  return A{};
}
const A& operator<=(A const& lhs, A const& rhs) noexcept // Non-compliant
{
  return lhs; 
}