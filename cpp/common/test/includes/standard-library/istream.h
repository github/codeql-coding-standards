#ifndef _GHLIBCPP_ISTREAM
#define _GHLIBCPP_ISTREAM

#include "ios.h"
#include "string.h"

namespace std {
template <class charT, class traits>
class basic_istream : virtual public basic_ios<charT, traits> {
public:
  using char_type = charT;
  using int_type = int; // typename traits::int_type;

  basic_istream<charT, traits> &operator>>(unsigned short &val);
  basic_istream<charT, traits> &operator>>(unsigned int &val);
  basic_istream<charT, traits> &operator>>(long &val);
  basic_istream<charT, traits> &operator>>(unsigned long &val);
  basic_istream<charT, traits> &operator>>(long long &val);
  basic_istream<charT, traits> &operator>>(unsigned long long &val);
  basic_istream<charT, traits> &operator>>(float &val);
  basic_istream<charT, traits> &operator>>(double &val);
  basic_istream<charT, traits> &operator>>(long double &val);
  basic_istream<charT, traits> &operator>>(bool &val);
  basic_istream<charT, traits> &operator>>(void *&val);
  basic_istream<charT, traits> &operator>>(short &val);
  basic_istream<charT, traits> &operator>>(int &n);

  explicit basic_istream(std::basic_streambuf<charT, traits> *sb);

  basic_istream<charT, traits> &operator>>(
      basic_istream<charT, traits> &(*pf)(basic_istream<charT, traits> &));
  basic_istream<charT, traits> &
  operator>>(basic_ios<charT, traits> &(*pf)(basic_ios<charT, traits> &));
  basic_istream<charT, traits> &operator>>(ios_base &(*pf)(ios_base &));

  streamsize gcount() const;
  int_type get();
  basic_istream<charT, traits> &get(char_type &c);
  basic_istream<charT, traits> &get(char_type *s, streamsize n);
  basic_istream<charT, traits> &ignore();
  int_type peek();
  basic_istream<charT, traits> &read(char_type *s, streamsize n);
  streamsize readsome(char_type *s, streamsize n);
  basic_istream<charT, traits> &putback(char_type c);
  basic_istream<charT, traits> &unget();
  int sync();

  pos_type tellg();
  basic_istream<charT, traits> &seekg(pos_type);

  basic_istream<charT, traits> &getline(char_type *s, streamsize n);
  basic_istream<charT, traits> &getline(char_type *s, streamsize n,
                                        char_type delim);

protected:
  basic_istream();
};

template <class charT, class traits, class Allocator>
basic_istream<charT, traits> &
operator>>(basic_istream<charT, traits> &is,
           basic_string<charT, traits, Allocator> &str);

template <class charT, class traits>
basic_istream<charT, traits> &operator>>(basic_istream<charT, traits> &in,
                                         charT *s);
template <class traits>
basic_istream<char, traits> &operator>>(basic_istream<char, traits> &in,
                                        unsigned char *s);
template <class traits>
basic_istream<char, traits> &operator>>(basic_istream<char, traits> &in,
                                        signed char *s);

template <class charT, class traits>
basic_istream<charT, traits> &operator>>(basic_istream<charT, traits> &in,
                                         charT &c);
template <class traits>
basic_istream<char, traits> &operator>>(basic_istream<char, traits> &in,
                                        unsigned char &c);
template <class traits>
basic_istream<char, traits> &operator>>(basic_istream<char, traits> &in,
                                        signed char &c);

template <class charT, class traits, class Allocator>
basic_istream<charT, traits> &
getline(basic_istream<charT, traits> &is,
        basic_string<charT, traits, Allocator> &str, charT delim);
template <class charT, class traits, class Allocator>
basic_istream<charT, traits> &
getline(basic_istream<charT, traits> &is,
        basic_string<charT, traits, Allocator> &str);
typedef basic_istream<char> istream;
} // namespace std

#endif // _LIBCPP_ISTREAM