namespace std {
template <class... Types> class tuple {};
template <class... Types> std::tuple<Types...> make_tuple(Types &&...args);
} // namespace std
