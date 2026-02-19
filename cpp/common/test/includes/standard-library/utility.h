#include "type_traits.h"
#ifndef _GHLIBCPP_UTILITY
#define _GHLIBCPP_UTILITY

namespace std {
template <class T> constexpr T &&forward(remove_reference_t<T> &t) noexcept;
template <class T> constexpr T &&forward(remove_reference_t<T> &&t) noexcept;
template <class T> constexpr remove_reference_t<T> &&move(T &&t) noexcept;

template <class T> typename add_rvalue_reference<T>::type declval() noexcept;

template <class T> void swap(T &a, T &b) noexcept;

template <class T1, class T2> struct pair {
  T1 first;
  T2 second;
  pair(const T1 &a, const T2 &b);
};

} // namespace std

#endif // _GHLIBCPP_UTILITY