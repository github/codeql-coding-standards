#ifndef _STL_FUNCTION_H
#define _STL_FUNCTION_H 1

namespace std {
template <typename _Tp> struct less {
  bool operator()(const _Tp &__x, const _Tp &__y) const { return __x < __y; }
};

template <typename _Tp> struct greater {
  bool operator()(const _Tp &__x, const _Tp &__y) const { return __x > __y; }
};

template <typename _Tp> struct greater_equal {
  bool operator()(const _Tp &__x, const _Tp &__y) const { return __x >= __y; }
};
template <typename _Tp> struct less_equal {
  bool operator()(const _Tp &__x, const _Tp &__y) const { return __x <= __y; }
};

} // namespace std
#endif