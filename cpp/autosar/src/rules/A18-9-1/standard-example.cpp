// $Id: A18-9-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint> 
#include <functional> 
class A
{
  // Implementation
};
void Fn(A const& a, double y) noexcept 
{
  // Implementation
}
void F1() noexcept
{
  double y = 0.0;
  auto function = std::bind(&Fn, std::placeholders::_1, y); // Non-compliant 
  // ...
  A const a{};
  function(a);
}
void F2() noexcept
{
  auto lambda = [](A const& a) -> void {
    double y = 0.0;
    Fn(a, y);
  }; // Compliant
  // ...
  A const a{};
  lambda(a);
}