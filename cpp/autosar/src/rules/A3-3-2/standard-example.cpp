// $Id: A3-3-2.cpp 305690 2018-01-29 14:35:00Z jan.babst $
#include <cstdint>
#include <limits>
#include <string>
class A
{
  public:
    static std::uint8_t instanceId;
    static float const pi;
    static std::string const separator;

    A() {}
    // Implementation...
};
std::uint8_t A::instanceId = 0;// Compliant - constant initialization
float const A::pi = 3.14159265359; // Compliant - constant initialization
std::string const A::separator =
     "=========="; // Non-compliant - string c’tor is not constexpr

class C
{
  public:
  constexpr C() = default;
};

namespace
{
  constexpr std::int32_t maxInt32 =
      std::numeric_limits<std::int32_t>::max(); // Compliant - constexpr variable

  A instance{}; // Compliant - constant (value) initialization
  constexpr C c{}; // Compliant - constexpr c’tor call
} // namespace

void Fn() noexcept
{
  static A a{}; // Non-compliant - A’s default c’tor is not constexpr
  static std::int32_t counter{0}; // Compliant
  static std::string border(5, '*'); // Non-compliant - not a constexpr c’tor

  class D
  {
    public:
      D() = default;
      D(D const&) = default;
      D(D&&) = default;
      D& operator=(D const&) = default;
      D& operator=(D&&) = default;
      ~D() = default;
    private:
      static D* instance;
};
D* D::instance = nullptr; // Compliant - initialization by constant expression