// $Id: A8-4-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <stdexcept>
std::int32_t F1() noexcept // Non-compliant
{}
std::int32_t F2(std::int32_t x) noexcept(false) {
  if (x > 100) {
    throw std::logic_error("Logic Error"); // Compliant by exception
  }

  return x; // Compliant
}
std::int32_t F3(std::int32_t x, std::int32_t y) {
  if (x > 100 || y > 100) {
    throw std::logic_error("Logic Error"); // Compliant by exception
  }
  if (y > x) {
    return (y - x); // Compliant
  }
  return (x - y); // Compliant
}