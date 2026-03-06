#ifndef _GHLIBCPP_EMPTY
#define _GHLIBCPP_EMPTY
#include <initializer_list>
#include <stddef.h>
/**
 * Not intended to be used via #include <empty.h>, and not part of the public
 * API.
 *
 * However, multiple libraries such as <array>, <deque>, etc define std::empty,
 * so this is the singular header to define it in the test suite.
 */

namespace std {
template <class C> constexpr auto empty(const C &c) -> decltype(c.empty());

template <class T, size_t N> constexpr bool empty(const T (&)[N]) noexcept;

template <class T> constexpr bool empty(std::initializer_list<T>) noexcept;
} // namespace std

#endif // _GHLIBCPP_EMPTY