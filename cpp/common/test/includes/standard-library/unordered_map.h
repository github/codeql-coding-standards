#ifndef _GHLIBCPP_UNORDERED_MAP
#define _GHLIBCPP_UNORDERED_MAP

#include <functional>
#include <initializer_list>
#include <utility>

namespace std {

template <typename K, typename V, typename Hash = std::hash<K>,
          typename KeyEqual = std::equal_to<K>,
          typename Allocator = std::allocator<std::pair<const K, V>>>
class unordered_map {
public:
  unordered_map();
  unordered_map(const unordered_map &);
  unordered_map(unordered_map &&);
  unordered_map(std::initializer_list<std::pair<const K, V>>);
  ~unordered_map();
};

template <typename K, typename V, typename Hash = std::hash<K>,
          typename KeyEqual = std::equal_to<K>,
          typename Allocator = std::allocator<std::pair<const K, V>>>
class unordered_multimap {
public:
  unordered_multimap();
  unordered_multimap(const unordered_multimap &);
  unordered_multimap(unordered_multimap &&);
  unordered_multimap(std::initializer_list<std::pair<const K, V>>);
  ~unordered_multimap();
};

} // namespace std

#endif // _GHLIBCPP_UNORDERED_MAP
