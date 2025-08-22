#ifndef _GHLIBCPP_OSTREAM
#define _GHLIBCPP_OSTREAM
#include <ios>
#include <string>

namespace std {
template <class charT, class traits>
class basic_ostream : virtual public basic_ios<charT, traits> {
public:
  typedef charT char_type;

  basic_ostream<charT, traits> &operator<<(int n);
  basic_ostream<charT, traits> &operator<<(bool n);
  basic_ostream<charT, traits> &operator<<(short n);
  basic_ostream<charT, traits> &operator<<(unsigned short n);
  basic_ostream<charT, traits> &operator<<(unsigned int n);
  basic_ostream<charT, traits> &operator<<(long n);
  basic_ostream<charT, traits> &operator<<(unsigned long n);
  basic_ostream<charT, traits> &operator<<(long long n);
  basic_ostream<charT, traits> &operator<<(unsigned long long n);
  basic_ostream<charT, traits> &operator<<(float f);
  basic_ostream<charT, traits> &operator<<(double f);
  basic_ostream<charT, traits> &operator<<(long double f);
  basic_ostream<charT, traits> &operator<<(const void *p);

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

template <class CharT, class Traits>
basic_ostream<CharT, Traits> &
operator<<(basic_ostream<CharT, Traits> &,
           std::ios_base &(*func)(std::ios_base &));
template <class CharT, class Traits>
basic_ostream<CharT, Traits> &operator<<(
    basic_ostream<CharT, Traits> &,
    std::basic_ios<CharT, Traits> &(*func)(std::basic_ios<CharT, Traits> &));

template <class charT, class traits>
basic_ostream<charT, traits> &operator<<(basic_ostream<charT, traits> &os,
                                         const void *p);

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