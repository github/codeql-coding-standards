#ifndef _GHLIBCPP_FORWARD_LIST
#define _GHLIBCPP_FORWARD_LIST

#include <initializer_list>
#include <memory>

namespace std {

template <typename T, typename Alloc = std::allocator<T>> class forward_list {
public:
  forward_list();
  forward_list(const forward_list &);
  forward_list(forward_list &&);
  forward_list(std::initializer_list<T>);
};

} // namespace std

#endif // _GHLIBCPP_FORWARD_LIST
