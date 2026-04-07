#ifndef _GHLIBCPP_UNORDERED_MAP
#define _GHLIBCPP_UNORDERED_MAP

#include <initializer_list>
#include <utility>

namespace std {

template<typename K, typename V>
class unordered_map {
public:
    unordered_map();
    unordered_map(const unordered_map&);
    unordered_map(unordered_map&&);
    unordered_map(std::initializer_list<std::pair<const K, V>>);
};

template<typename K, typename V>
class unordered_multimap {
public:
    unordered_multimap();
    unordered_multimap(const unordered_multimap&);
    unordered_multimap(unordered_multimap&&);
    unordered_multimap(std::initializer_list<std::pair<const K, V>>);
};

} // namespace std

#endif // _GHLIBCPP_UNORDERED_MAP
