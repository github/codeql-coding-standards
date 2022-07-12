// $Id: A7-1-5.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <vector>

class A {};
void F1() noexcept {
  auto x1 = 5;    // Non-compliant - initializer is of fundamental type
  auto x2 = 0.3F; // Non-compliant - initializer is of fundamental type
  auto x3 = {8};  // Non-compliant - initializer is of fundamental type

  std::vector<std::int32_t> v;
  auto x4 = v.size(); // Compliant with case (1) - x4 is of size_t type that
  // is returned from v.size() method

  auto a = A{}; // Compliant with case (2)

  auto lambda1 = []() -> std::uint16_t {
    return 5U;
  }; // Compliant with case (2) - lambda1 is of non-fundamental lambda
     // expression type
  auto x5 = lambda1(); // Compliant with case (1) - x5 is of
                       // std::uint16_t type
}
void F2() noexcept {
  auto lambda1 = [](auto x, auto y) -> decltype(x + y) {
    return (x + y);
  };                          // Compliant with cases (2) and (3)
  auto y1 = lambda1(5.0, 10); // Compliant with case (1)
}
template <typename T, typename U>
auto F3(T t, U u) noexcept -> decltype(t + u) // Compliant with case (4)
{
  return (t + u);
}
template <typename T> class B {
public:
  T Fn(T t);
};
template <typename T>
auto B<T>::Fn(T t) -> T // Compliant with case (4)
{
  // ...
  return t;
}