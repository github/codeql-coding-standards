// $Id: A14-7-2.cpp 312645 2018-03-21 11:44:35Z michal.szczepankiewicz $
#include <cstdint>
//in A.hpp
#include <functional>
struct A
{
  std::uint8_t x;
};

namespace std {
  //compliant, case (2)
  //template specialization for the user-defined type
  //in the same file as the type declaration
  template <>
  struct hash<A>
  {
    size_t operator()(const A& a) const noexcept
    {
      return std::hash<decltype(a.x)>()(a.x);
    }
  };
}

//traits.hpp
#include <type_traits>
#include <cstdint>
template <typename T>
struct is_serializable : std::false_type {};

//compliant, case (1)
template <>
struct is_serializable<std::uint8_t> : std::true_type {};

//func.cpp
#include <vector>
//non-compliant, not declared
//in the same file as
//is_serializable class
template <>
struct is_serializable<std::uint16_t> : std::true_type {};

template <typename T, typename = std::enable_if<is_serializable<T>::value>> 
    std::vector<std::uint8_t> serialize(const T& t)
{
  //only a basic stub
  return std::vector<std::uint8_t>{t}; 
}

#include <string>
int main()
{ 
  serialize(std::uint8_t{3}); 
}