#ifndef _GHLIBCPP_OSTREAM
#define _GHLIBCPP_OSTREAM
#include "string.h"
#include <ios>

namespace std {
template <class charT, class traits>
class basic_ostream : virtual public basic_ios<charT, traits> {
public:
  typedef charT char_type;

  basic_ostream<charT, traits> &operator<<(int n);

  basic_ostream<charT, traits> &put(char_type c);
  basic_ostream<charT, traits> &write(const char_type *s, streamsize n);
  basic_ostream<charT, traits> &flush();
  pos_type tellp();
  basic_ostream<charT, traits> &seekp(pos_type);
};

template <class charT, class traits>
basic_ostream<charT, traits> &operator<<(basic_ostream<charT, traits> &,
                                         const charT *);
template <class charT, class traits>
basic_ostream<charT, traits> &operator<<(
    basic_ostream<charT, traits> &,
    basic_ostream<charT, traits> &(*func)(basic_ostream<charT, traits> &));
template <class charT, class traits>
basic_ostream<charT, traits> &endl(basic_ostream<charT, traits> &);

template <class charT, class traits, class Allocator>
basic_ostream<charT, traits> &
operator<<(basic_ostream<charT, traits> &os,
           const basic_string<charT, traits, Allocator> &str);

template <class charT, class traits>
class basic_iostream : public basic_istream<charT, traits>,
                       public basic_ostream<charT, traits> {
public:
};
typedef basic_ostream<char> ostream;
} // namespace std
#endif // _GHLIBCPP_OSTREAM