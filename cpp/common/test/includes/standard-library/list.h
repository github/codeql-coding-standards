#ifndef _GHLIBCPP_LIST

#define _GHLIBCPP_LIST

#include <initializer_list>
#include <memory>

namespace std {

template <typename T, typename Alloc = std::allocator<T>> class list {
public:
  list();
  list(const list &);
  list(list &&);
  list(std::initializer_list<T>);
};

} // namespace std

#endif // _GHLIBCPP_LIST
