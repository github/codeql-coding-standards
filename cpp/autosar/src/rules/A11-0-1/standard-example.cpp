// $Id: A11-0-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <limits>
class A // Compliant - A provides user-defined constructors, invariant and
        // interface
{
    std::int32_t x; // Data member is private by default
  public:
    static constexpr std::int32_t maxValue =
           std::numeric_limits<std::int32_t>::max(); 
    A() : x(maxValue) {}
    explicit A(std::int32_t number) : x(number) {} 
    A(A const&) = default;
    A(A&&) = default;
    A& operator=(A const&) = default;
    A& operator=(A&&) = default;

    std::int32_t GetX() const noexcept { return x; }
    void SetX(std::int32_t number) noexcept { x = number; } 
};
struct B // Non-compliant - non-POD type defined as struct 
{
  public:
    static constexpr std::int32_t maxValue =
           std::numeric_limits<std::int32_t>::max(); 
    B() : x(maxValue) {}
    explicit B(std::int32_t number) : x(number) {} 
    B(B const&) = default;
    B(B&&) = default;
    B& operator=(B const&) = default;
    B& operator=(B&&) = default;

    std::int32_t GetX() const noexcept { return x; }
    void SetX(std::int32_t number) noexcept { x = number; }

  private:
    std::int32_t x; // Need to provide private access specifier for x member
};
struct C // Compliant - POD type defined as struct 
{
  std::int32_t x;
  std::int32_t y; 
};
class D // Compliant - POD type defined as class, but not compliant with 
        // M11-0-1
{
  public:
    std::int32_t x;
    std::int32_t y; 
};