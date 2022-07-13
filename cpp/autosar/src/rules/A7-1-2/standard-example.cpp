//% $Id: A7-1-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
std::int32_t Pow1(std::int32_t number)
{
  return (number * number); 
}
constexpr std::int32_t Pow2(
    std::int32_t number) // Possible compile-time computing
                         // because of constexpr specifier
{
  return (number * number);
}
void Fn() 
{
  constexpr std::int16_t i1 = 20; // Compliant, evaluated at compile-time 
  const std::int16_t i2 = 20;     // Non-compliant, possible run-time evaluation 
  std::int32_t twoSquare =
      Pow1(2); // Non-compliant, possible run-time evaluation 
  const std::int32_t threeSquare =
      Pow1(3); // Non-compliant, possible run-time evaluation
  // static_assert(threeSquare == 9, "pow1(3) did not succeed."); // Value 
  // can not be static_assert-ed
  constexpr std::int32_t fiveSquare =
      Pow2(5); // Compliant, evaluated at compile time 
  static_assert(fiveSquare == 25,
                "pow2(5) did not succeed."); // Compliant, constexpr
                                             // evaluated at compile time
  // constexpr std::int32_t int32Max =
  // std::numeric_limits<std::int32_t>::max() + 1; // 
  // Compliant - compilation error due to
  // compile-time evaluation (integer overflow)
}
class A 
{
  public:
    static constexpr double pi = 3.14159265; // Compliant - value of PI can be
                                             // determined in compile time
    // constexpr double e = 2.71828182; // Non-compliant - constexprs need 
    // to be static members, compilation error

    constexpr A() = default; // Compliant 
};