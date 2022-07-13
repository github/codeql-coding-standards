#include "type_traits.h"

namespace std {
template <class T> constexpr T &&forward(remove_reference_t<T> &t) noexcept;
template <class T> constexpr T &&forward(remove_reference_t<T> &&t) noexcept;
template <class T> constexpr remove_reference_t<T> &&move(T &&t) noexcept;

template <class T> typename add_rvalue_reference<T>::type declval() noexcept;

template <class T> void swap(T &a, T &b) noexcept;
} // namespace std