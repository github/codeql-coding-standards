#include <cstdint>

// @brief func1
// @return exit code
int32_t func1(void) noexcept { // COMPLIANT
    int32_t x; // CAUTION: uninitialized!!
    int32_t ret;
    ret = func2(x);
    return ret;
}

// @brief func2
// @param arg parameter
// @return exit code
int32_t func2(const int32_t arg) // COMPLIANT
{
    int32_t ret;
    ret = arg * arg;
    return ret;
}

namespace mains {
    static int32_t var;

    // @brief namespace_func
    static void namespace_func(void) noexcept { // COMPLIANT
        mains::var = -1;
        return;
    }
}  // namespace

// @brief main
// @return exit code
int32_t main(void) {
    int32_t ret {0};
    try {
        ret = func1();
        mains::var += ret;
    }
    catch(...) {
        mains::namespace_func();
    }
    return ret;
}
