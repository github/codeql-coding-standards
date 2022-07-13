// $Id: A13-5-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
class Container1
{
  public:
    std::int32_t& operator[](
    std::int32_t index) // Compliant - non-const version 
    {
      return container[index]; 
    }
    std::int32_t operator[](
    std::int32_t index) const // Compliant - const version
    {
      return container[index];
    }

  private:
    static constexpr std::int32_t maxSize = 10;
    std::int32_t container[maxSize];
};
void Fn() noexcept
{
  Container1 c1;
  std::int32_t e = c1[0]; // Non-const version called
  c1[0] = 20; // Non-const version called Container1 const c2{};
  e = c2[0]; // Const version called
  // c2[0] = 20; // Compilation error
}
class Container2 // Non-compliant - only non-const version of operator[]
                 // implemented
{
  public:
    std::int32_t& operator[](std::int32_t index) { return container[index]; }

  private:
    static constexpr std::int32_t maxSize = 10;
    std::int32_t container[maxSize];
};