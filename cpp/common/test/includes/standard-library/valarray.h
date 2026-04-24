#ifndef _GHLIBCPP_VALARRAY
#define _GHLIBCPP_VALARRAY

#include <initializer_list>

namespace std {

template <typename T> class valarray {
public:
  valarray();
  valarray(const valarray &);
  valarray(valarray &&);
  valarray(std::size_t);
  valarray(std::initializer_list<T>);
  ~valarray();
};

} // namespace std

#endif // _GHLIBCPP_VALARRAY
