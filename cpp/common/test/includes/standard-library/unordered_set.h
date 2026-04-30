#ifndef _GHLIBCPP_UNORDERED_SET
#define _GHLIBCPP_UNORDERED_SET

#include <initializer_list>
#include <vector>

namespace std {

template <typename T, typename Hash = std::hash<T>,
          typename Equal = std::equal_to<T>,
          typename Allocator = std::allocator<T>>
class unordered_set {
public:
  unordered_set();
  unordered_set(const unordered_set &);
  unordered_set(unordered_set &&);
  unordered_set(std::initializer_list<T>);
  ~unordered_set();
};

template <typename T, typename Hash = std::hash<T>,
          typename Equal = std::equal_to<T>,
          typename Allocator = std::allocator<T>>
class unordered_multiset {
public:
  unordered_multiset();
  unordered_multiset(const unordered_multiset &);
  unordered_multiset(unordered_multiset &&);
  unordered_multiset(std::initializer_list<T>);
  ~unordered_multiset();
};

} // namespace std

#endif // _GHLIBCPP_UNORDERED_SET
