namespace std {
template <class... Types> class tuple {};
template <class... Types> std::tuple<Types...> make_tuple(Types &&...args);
struct ignore_t {
  template <typename T>
  constexpr // required since C++14
      void
      operator=(T &&) const noexcept {}
};
inline const std::ignore_t ignore; // 'const' only until C++17
} // namespace std
