//% $Id: A2-7-3.hpp 305382 2018-01-26 06:32:15Z michal.szczepankiewicz $
#include <cstdint>

void F1(std::int32_t) noexcept; // Non-compliant documentation
 
std::int32_t F2(std::int16_t input1,
                std::int32_t input2); // Non-compliant documentation
/// @brief Function description
///
/// @param input1 input1 parameter description
/// @param input2 input2 parameter description
/// @throw std::runtime_error conditions to runtime_error occur
///
/// @return return value description
std::int32_t F3(
      std::int16_t input1,
      std::int16_t input2) noexcept(false); // Compliant documentation

/// @brief Class responsibility
class C // Compliant documentation
{
  public:
    /// @brief Constructor description
    ///
    /// @param input1 input1 parameter description
    /// @param input2 input2 parameter description
    C(std::int32_t input1, float input2) : x{input1}, y{input2} {}

    /// @brief Method description
    ///
    /// @return return value description
    std::int32_t const* GetX() const noexcept { return &x; }
 
  private:
    /// @brief Data member description 
    std::int32_t x;
    /// @brief Data member description 
    float y;
};
