#ifndef _GHLIBCPP_CSTDLIB
#define _GHLIBCPP_CSTDLIB
#include "stdlib.h"
namespace std {
[[noreturn]] void _Exit(int status) noexcept;
[[noreturn]] void abort(void) noexcept;
[[noreturn]] void quick_exit(int status) noexcept;
extern "C++" int atexit(void (*f)(void)) noexcept;
extern "C++" int at_quick_exit(void (*f)(void)) noexcept;
using ::atof;
using ::atoi;
using ::atol;
using ::atoll;
using ::rand;
} // namespace std
#endif // _GHLIBCPP_CSTDLIB