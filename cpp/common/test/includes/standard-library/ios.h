#ifndef _GHLIBCPP_IOS
#define _GHLIBCPP_IOS
#include "iosfwd.h"
#include "stddef.h"
namespace std {
typedef size_t streamsize;
typedef int pos_type;

// Bitmask type as specified by [bitmask.types]
// Operators omitted as not required for our test cases
enum _iostate_impl {
  _goodbit = 0,
  _badbit = 1 << 0,
  _eofbit = 1 << 1,
  _failbit = 1 << 2
};

constexpr _iostate_impl operator&(_iostate_impl X, _iostate_impl Y) {
  return static_cast<_iostate_impl>(static_cast<int>(X) & static_cast<int>(Y));
}
constexpr _iostate_impl operator|(_iostate_impl X, _iostate_impl Y) {
  return static_cast<_iostate_impl>(static_cast<int>(X) | static_cast<int>(Y));
}
constexpr _iostate_impl operator^(_iostate_impl X, _iostate_impl Y) {
  return static_cast<_iostate_impl>(static_cast<int>(X) ^ static_cast<int>(Y));
}
constexpr _iostate_impl operator~(_iostate_impl X) {
  return static_cast<_iostate_impl>(~static_cast<int>(X));
}
_iostate_impl &operator&=(_iostate_impl &X, _iostate_impl Y) {
  X = X & Y;
  return X;
}
_iostate_impl &operator|=(_iostate_impl &X, _iostate_impl Y) {
  X = X | Y;
  return X;
}
_iostate_impl &operator^=(_iostate_impl &X, _iostate_impl Y) {
  X = X ^ Y;
  return X;
}

class ios_base {
public:
  typedef _iostate_impl iostate;
  static constexpr iostate goodbit = _goodbit;
  static constexpr iostate badbit = _badbit;
  static constexpr iostate eofbit = _eofbit;
  static constexpr iostate failbit = _failbit;
};

template <class charT, class traits> class basic_ios : public std::ios_base {
public:
  explicit operator bool() const;
  bool operator!() const;
  iostate rdstate() const;
  void clear(iostate state = goodbit);
  void setstate(iostate state);
  bool good() const;
  bool eof() const;
  bool fail() const;
  bool bad() const;

  iostate exceptions() const;
  void exceptions(iostate except);
};

ios_base &hex(ios_base &str);

} // namespace std
#endif // _GHLIBCPP_IOS