#include <ios>
#include <istream>
#include <ostream>
#include <streambuf>

namespace std {
typedef basic_iostream<char> iostream;

class strstreambuf : public basic_streambuf<char> {};

class istrstream : public istream {
public:
  explicit istrstream(const char *);
  explicit istrstream(char *);
  istrstream(const char *, streamsize);
  istrstream(char *, streamsize);
};

class ostrstream : public ostream {
public:
  ostrstream();
};

class strstream : public iostream {
public:
  strstream();
};
} // namespace std