#ifndef _GHLIBCPP_LIST
#define _GHLIBCPP_LIST

#include <initializer_list>

namespace std {

template<typename T>
class list {
public:
    list();
    list(const list&);
    list(list&&);
    list(std::initializer_list<T>);
};

} // namespace std

#endif // _GHLIBCPP_LIST
