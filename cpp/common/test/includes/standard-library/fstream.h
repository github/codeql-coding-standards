#ifndef _GHLIBCPP_FSTREAM
#define _GHLIBCPP_FSTREAM
#include "istream.h"
#include "ostream.h"

namespace std {
template <class CharT, class Traits>
class basic_fstream : public std::basic_iostream<CharT, Traits> {
public:
  // constructors
  basic_fstream();
  explicit basic_fstream(const char *s);
  // members
  bool is_open() const;
  void open(const string &s);
  void close();
};
using fstream = basic_fstream<char>;
} // namespace std

#endif // _GHLIBCPP_FSTREAM