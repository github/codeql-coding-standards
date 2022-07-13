#ifndef _GHLIBCPP_TYPE_TRAITS
#define _GHLIBCPP_TYPE_TRAITS
#include "stddef.h"
template <class T> struct remove_const { typedef T type; };

template <class T> struct remove_const<const T> { typedef T type; };

template <class T> using remove_const_t = typename remove_const<T>::type;

template <class T> struct remove_reference { typedef T type; };

template <class T> struct remove_reference<T &> { typedef T type; };

template <class T> struct remove_reference<T &&> { typedef T type; };

template <class T>
using remove_reference_t = typename remove_reference<T>::type;

template <class T> struct decay_impl { typedef T type; };

template <class T, size_t t_size> struct decay_impl<T[t_size]> {
  typedef T *type;
};

template <class T>
using decay_t = typename decay_impl<remove_reference_t<T>>::type;

namespace detail {

template <class T> struct type_identity { using type = T; };

template <class T> auto try_add_lvalue_reference(int) -> type_identity<T &>;
template <class T> auto try_add_lvalue_reference(...) -> type_identity<T>;

template <class T> auto try_add_rvalue_reference(int) -> type_identity<T &&>;
template <class T> auto try_add_rvalue_reference(...) -> type_identity<T>;

} // namespace detail

template <class T>
struct add_lvalue_reference : decltype(detail::try_add_lvalue_reference<T>(0)) {
};

template <class T>
struct add_rvalue_reference : decltype(detail::try_add_rvalue_reference<T>(0)) {
};

namespace std {
template <typename T> struct is_array { const static bool value = false; };

template <typename T> struct is_array<T[]> { const static bool value = true; };

template <typename T, unsigned int N> struct is_array<T[N]> {
  const static bool value = true;
};

template <typename T> struct remove_extent { typedef T type; };

template <typename T> struct remove_extent<T[]> { typedef T type; };

template <typename T, unsigned int N> struct remove_extent<T[N]> {
  typedef T type;
};

template <class T> struct is_trivially_copy_constructible {
  const static bool value = true;
  constexpr operator bool() { return value; }
};

template <class T> struct is_trivially_move_constructible {
  const static bool value = true;
  constexpr operator bool() { return value; }
};

template <class T> struct is_trivially_copy_assignable {
  const static bool value = true;
  constexpr operator bool() { return value; }
};

template <class T> struct is_trivially_move_assignable {
  const static bool value = true;
  constexpr operator bool() { return value; }
};

} // namespace std
#endif // _GHLIBCPP_TYPE_TRAITS