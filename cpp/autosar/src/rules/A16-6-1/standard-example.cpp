// $Id: A16-6-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <type_traits>
constexpr std::int32_t value = 0;
#if value > 10
  #error "Incorrect value" // Non-compliant 
#endif
void F1() noexcept
{
  static_assert(value <= 10, "Incorrect value"); // Compliant 
  // ...
}
template <typename T>
void F2(T& a)
{ 
  static_assert(std::is_copy_constructible<T>::value,
                "f2() function requires copying"); // Compliant
  // ... 
}