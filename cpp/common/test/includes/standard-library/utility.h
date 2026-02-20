#include "type_traits.h"

namespace std {
template <class T> constexpr T &&forward(remove_reference_t<T> &t) noexcept {
    return static_cast<T&&>(t);
}
template <class T> constexpr T &&forward(remove_reference_t<T> &&t) noexcept {
    return static_cast<T&&>(t);
}

template <class T> constexpr remove_reference_t<T> &&move(T &&t) noexcept;

template <class T> typename add_rvalue_reference<T>::type declval() noexcept;

template <class T> void swap(T &a, T &b) noexcept;

template<class... Types>
struct tuple {};

template <class T, class U> struct pair : tuple<T, U> {
    T first;
    U second;
    pair(T t, U u);
};
template <class T, class U> std::pair<T, U> make_pair(T &&x, U &&y);

template<size_t N, class T, class U>
constexpr auto get(const std::pair<T, U> &p) noexcept {
    if constexpr (N == 0) {
        return p.first;
    } else if constexpr (N == 1) {
        return p.second;
    } else {
        static_assert(N < 2, "Index out of bounds for pair");
    }
}
} // namespace std