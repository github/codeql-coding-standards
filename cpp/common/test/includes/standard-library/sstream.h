#ifndef _GHLIBCPP_SSTREAM
#define _GHLIBCPP_SSTREAM
#include "istream.h"
#include "ostream.h"

namespace std {
template <class CharT, class Traits, class Allocator>
class basic_stringstream : public basic_iostream<CharT, Traits> {
public:
  basic_stringstream();
  basic_stringstream(const basic_stringstream &);
  basic_stringstream(basic_stringstream &&);
  basic_stringstream(const CharT *);
};

template <typename CharT, class Traits, class Allocator>
class basic_istringstream {
public:
  basic_istringstream();
  basic_istringstream(const basic_istringstream &);
  basic_istringstream(basic_istringstream &&);
  basic_istringstream(const CharT *);
};

template <typename CharT, class Traits, class Allocator>
class basic_ostringstream {
public:
  basic_ostringstream();
  basic_ostringstream(const basic_ostringstream &);
  basic_ostringstream(basic_ostringstream &&);
};

using stringstream = basic_stringstream<char>;
using wstringstream = basic_stringstream<wchar_t>;
using istringstream = basic_istringstream<char>;
using wistringstream = basic_istringstream<wchar_t>;
using ostringstream = basic_ostringstream<char>;
using wostringstream = basic_ostringstream<wchar_t>;
} // namespace std

#endif // _GHLIBCPP_SSTREAM
