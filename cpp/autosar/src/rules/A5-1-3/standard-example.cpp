// $Id: A5-1-3.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
void Fn()
{
  std::int32_t i = 0;
  std::int32_t j = 0;
  auto lambda1 = [&i, &j] { ++i, ++j; }; // Non-compliant
  auto lambda2 = [&i, &j]() {
    ++i;
    ++j;
  }; // Compliant
}