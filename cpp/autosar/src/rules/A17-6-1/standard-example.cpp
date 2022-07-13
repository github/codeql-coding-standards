// $Id: A17-6-1.cpp 305588 2018-01-29 11:07:35Z michal.szczepankiewicz $
#include <cstdint> 
#include <limits> 
#include <memory> 
#include <type_traits> 
#include <utility>
namespace std
{
  // Non-compliant - An alias definition is added to namespace std.
  // This is a compile error in C++17, since std::byte is already defined.
  using byte = std::uint8_t;

  // Non-compliant - A function definition added to namespace std.
  pair<int, int> operator+(pair<int, int> const& x, pair<int, int> const& y)
  {
    return pair<int, int>(x.first + y.first, x.second + y.second);
  }

} // namespace std

struct MyType
{
  int value;
};

namespace std
{
  // Non-compliant - std::numeric_limits may not be specialized for
  // non-arithmetic types [limits.numeric].
  template <>
  struct numeric_limits<MyType> : numeric_limits<int>
  {
  };

  // Non-compliant - Structures in <type_traits>, except for std::common_type, // may not be specialized [meta.type.synop].
  template <>
  struct is_arithmetic<MyType> : true_type
  {
  };

  // Compliant - std::hash may be specialized for a user type if the
  // specialization fulfills the requirements in [unord.hash].
  template <>
  struct hash<MyType>
  {
    using result_type = size_t; // deprecated in C++17 using argument_type = MyType; // deprecated in C++17
    size_t operator()(MyType const& x) const noexcept
    {
      return hash<int>()(x.value);
    }
  };
} // namespace std