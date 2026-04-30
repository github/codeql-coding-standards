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
  basic_fstream(const basic_fstream &);
  basic_fstream(basic_fstream &&);
  virtual ~basic_fstream();
  // members
  bool is_open() const;
  void open(const string &s);
  void close();
};

template <typename CharT, class Traits> class basic_ifstream {
public:
  basic_ifstream();
  basic_ifstream(const basic_ifstream &);
  basic_ifstream(basic_ifstream &&);
  basic_ifstream(const char *);
};

template <typename CharT, class Traits> class basic_ofstream {
public:
  basic_ofstream();
  basic_ofstream(const basic_ofstream &);
  basic_ofstream(basic_ofstream &&);
  basic_ofstream(const char *);
};

using fstream = basic_fstream<char>;
using wfstream = basic_fstream<wchar_t>;
using ifstream = basic_ifstream<char>;
using wifstream = basic_ifstream<wchar_t>;
using ofstream = basic_ofstream<char>;
using wofstream = basic_ofstream<wchar_t>;
} // namespace std

#endif // _GHLIBCPP_FSTREAM
