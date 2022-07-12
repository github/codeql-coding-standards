// $Id: A5-1-4.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <functional>
std::function<std::int32_t()> F()
{
  std::int32_t i = 12;
  return ([&i]() -> std::int32_t {
    i = 100;
    return i;
  }); // Non-compliant
}
std::function<std::int32_t()> G()
{
  std::int32_t i = 12;
  return ([i]() mutable -> std::int32_t { return ++i; }); // Compliant
}
void Fn()
{
  auto lambda1 = F();
  std::int32_t i = lambda1(); // Undefined behavior
  auto lambda2 = G();
  i = lambda2(); // lambda2() returns 13
}