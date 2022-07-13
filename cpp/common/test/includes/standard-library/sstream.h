#ifndef _GHLIBCPP_SSTREAM
#define _GHLIBCPP_SSTREAM
#include "istream.h"
#include "ostream.h"

namespace std {
template <class CharT, class Traits, class Allocator>
class basic_stringstream : public basic_iostream<CharT, Traits> {
public:
  basic_stringstream() {}
};
} // namespace std

#endif // _GHLIBCPP_SSTREAM