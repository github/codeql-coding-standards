#ifndef _GHLIBCPP_UNORDERED_SET
#define _GHLIBCPP_UNORDERED_SET

#include <initializer_list>

namespace std {

template<typename T>
class unordered_set {
public:
    unordered_set();
    unordered_set(const unordered_set&);
    unordered_set(unordered_set&&);
    unordered_set(std::initializer_list<T>);
};

template<typename T>
class unordered_multiset {
public:
    unordered_multiset();
    unordered_multiset(const unordered_multiset&);
    unordered_multiset(unordered_multiset&&);
    unordered_multiset(std::initializer_list<T>);
};

} // namespace std

#endif // _GHLIBCPP_UNORDERED_SET
