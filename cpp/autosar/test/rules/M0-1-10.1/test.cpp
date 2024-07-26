#include <cstdint>

namespace mains {
static std::int32_t var;

// @brief namespace_func
static void
namespace_func(void) noexcept { // COMPLIANT: Called from "main" below.
  mains::var = -1;
  return;
}
} // namespace mains

std::int32_t func2() // COMPLIANT: Called from func1
{
  return mains::var + 20;
}

std::int32_t func1() {         // COMPLIANT: Called from main
  return mains::var + func2(); // func2 called here.
}

std::int32_t uncalled_func() // NON_COMPLIANT: Not called.
{
  return mains::var + func1(); // func1 called here.
}

// @brief main
// @return exit code
std::int32_t main(void) {
  std::int32_t ret{0};
  try {
    ret = func1(); // func1 called here.
    mains::var += ret;
  } catch (...) {
    mains::namespace_func(); // namespace_func called here.
  }
  return ret;
}
