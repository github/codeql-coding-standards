#include <ios>
#include <istream>
#include <ostream>
#include <streambuf>

namespace std {
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
} // namespace std