// $Id: A6-6-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
namespace
{
    constexpr std::int32_t loopLimit = 100;
}
void F1(std::int32_t n) noexcept
{
    if (n < 0) {
        // goto exit; // Non-compliant - jumping to exit from here crosses ptr 
        // pointer initialization, compilation
        // error
    }
    std::int32_t* ptr = new std::int32_t(n);
    // ... exit:
    delete ptr; 
}
void F2() noexcept {
    // ...
    goto error; // Non-compliant 
// ...
error:; // Error handling and cleanup 
}
void F3() noexcept
{
    for (std::int32_t i = 0; i < loopLimit; ++i) {
        for (std::int32_t j = 0; j < loopLimit; ++j) {
            for (std::int32_t k = 0; k < loopLimit; ++k) {
                if ((i == j) && (j == k)) {
                    // ...
                    goto loop_break; // Non-compliant 
                }
            }
        }
    }
loop_break:; // ...
}