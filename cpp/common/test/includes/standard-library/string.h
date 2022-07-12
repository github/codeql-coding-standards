#ifndef _GHLIBCPP_STRING
#define _GHLIBCPP_STRING
#include "errno.h"
#include "initializer_list"
#include "iosfwd.h"
#include "iterator.h"
#include "stddef.h"

namespace std {
template <class charT> struct char_traits;

template <class T> class allocator {
public:
  allocator() throw();
  typedef size_t size_type;
};

template <class charT, class traits = char_traits<charT>,
          class Allocator = allocator<charT>>
class basic_string {
public:
  using value_type = charT;
  using reference = value_type &;
  using const_reference = const value_type &;
  typedef typename Allocator::size_type size_type;
  static const size_type npos = -1;

  basic_string() : basic_string(Allocator()) {}
  explicit basic_string(const Allocator &a);
  basic_string(const basic_string &str);
  basic_string(basic_string &&str) noexcept;
  basic_string(const charT *s, size_type n, const Allocator &a = Allocator());
  basic_string(const charT *s, const Allocator &a = Allocator());
  basic_string(size_type n, charT c, const Allocator &a = Allocator());
  template <class InputIterator>
  basic_string(InputIterator begin, InputIterator end,
               const Allocator &a = Allocator());

  ~basic_string();
  basic_string &operator=(const basic_string &str);
  basic_string &operator=(basic_string &&str) noexcept;
  basic_string &operator=(const charT *s);
  basic_string &operator=(charT c);
  basic_string &operator=(initializer_list<charT>);

  const charT *c_str() const;
  charT *data() noexcept;
  size_type size() const noexcept;
  size_type length() const noexcept;

  typedef __iterator<charT> iterator;
  typedef __iterator<const charT> const_iterator;

  iterator begin();
  iterator end();
  const_iterator begin() const;
  const_iterator end() const;
  const_iterator cbegin() const;
  const_iterator cend() const;

  const charT &front() const;
  charT &front();
  const charT &back() const;
  charT &back();

  const_reference operator[](size_type pos) const;
  reference operator[](size_type pos);
  const_reference at(size_type n) const;
  reference at(size_type n);
  basic_string &operator+=(const basic_string &str);
  basic_string &operator+=(const charT *s);
  basic_string &operator+=(charT c);
  basic_string &operator+=(initializer_list<charT>);
  basic_string &append(const basic_string &str);
  basic_string &append(const basic_string &str, size_type pos,
                       size_type n = npos);
  basic_string &append(const charT *s, size_type n);
  basic_string &append(const charT *s);
  basic_string &append(size_type n, charT c);
  template <class InputIterator>
  basic_string &append(InputIterator first, InputIterator last);
  basic_string &append(initializer_list<charT>);
  void push_back(charT c);
  basic_string &assign(const basic_string &str);
  basic_string &assign(basic_string &&str) noexcept;
  basic_string &assign(const basic_string &str, size_type pos,
                       size_type n = npos);
  basic_string &assign(const charT *s, size_type n);
  basic_string &assign(const charT *s);
  basic_string &assign(size_type n, charT c);
  template <class InputIterator>
  basic_string &assign(InputIterator first, InputIterator last);
  basic_string &assign(initializer_list<charT>);
  basic_string &insert(size_type pos1, const basic_string &str);
  basic_string &insert(size_type pos1, const basic_string &str, size_type pos2,
                       size_type n = npos);
  basic_string &insert(size_type pos, const charT *s, size_type n);
  basic_string &insert(size_type pos, const charT *s);
  basic_string &insert(size_type pos, size_type n, charT c);
  iterator insert(const_iterator p, charT c);
  iterator insert(const_iterator p, size_type n, charT c);
  template <class InputIterator>
  iterator insert(const_iterator p, InputIterator first, InputIterator last);
  iterator insert(const_iterator p, initializer_list<charT>);
  basic_string &erase(size_type pos = 0, size_type n = npos);
  iterator erase(const_iterator p);
  iterator erase(const_iterator first, const_iterator last);
  basic_string &replace(size_type pos1, size_type n1, const basic_string &str);
  basic_string &replace(size_type pos1, size_type n1, const basic_string &str,
                        size_type pos2, size_type n2 = npos);
  basic_string &replace(size_type pos, size_type n1, const charT *s,
                        size_type n2);
  basic_string &replace(size_type pos, size_type n1, const charT *s);
  basic_string &replace(size_type pos, size_type n1, size_type n2, charT c);
  basic_string &replace(const_iterator i1, const_iterator i2,
                        const basic_string &str);
  basic_string &replace(const_iterator i1, const_iterator i2, const charT *s,
                        size_type n);
  basic_string &replace(const_iterator i1, const_iterator i2, const charT *s);
  basic_string &replace(const_iterator i1, const_iterator i2, size_type n,
                        charT c);
  template <class InputIterator>
  basic_string &replace(const_iterator i1, const_iterator i2, InputIterator j1,
                        InputIterator j2);
  basic_string &replace(const_iterator, const_iterator,
                        initializer_list<charT>);

  size_type copy(charT *s, size_type n, size_type pos = 0) const;
  void clear() noexcept;
  void swap(basic_string &s) noexcept;

  size_type find(const basic_string &str, size_type pos = 0) const noexcept;
  size_type find(const charT *s, size_type pos, size_type n) const;
  size_type find(const charT *s, size_type pos = 0) const;
  size_type find(charT c, size_type pos = 0) const;
  size_type rfind(const basic_string &str, size_type pos = npos) const noexcept;
  size_type rfind(const charT *s, size_type pos, size_type n) const;
  size_type rfind(const charT *s, size_type pos = npos) const;
  size_type rfind(charT c, size_type pos = npos) const;
  size_type find_first_of(const basic_string &str,
                          size_type pos = 0) const noexcept;
  size_type find_first_of(const charT *s, size_type pos, size_type n) const;
  size_type find_first_of(const charT *s, size_type pos = 0) const;
  size_type find_first_of(charT c, size_type pos = 0) const;
  size_type find_last_of(const basic_string &str,
                         size_type pos = npos) const noexcept;
  size_type find_last_of(const charT *s, size_type pos, size_type n) const;
  size_type find_last_of(const charT *s, size_type pos = npos) const;
  size_type find_last_of(charT c, size_type pos = npos) const;
  size_type find_first_not_of(const basic_string &str,
                              size_type pos = 0) const noexcept;
  size_type find_first_not_of(const charT *s, size_type pos, size_type n) const;
  size_type find_first_not_of(const charT *s, size_type pos = 0) const;
  size_type find_first_not_of(charT c, size_type pos = 0) const;
  size_type find_last_not_of(const basic_string &str,

                             size_type pos = npos) const noexcept;
  size_type find_last_not_of(const charT *s, size_type pos, size_type n) const;
  size_type find_last_not_of(const charT *s, size_type pos = npos) const;
  size_type find_last_not_of(charT c, size_type pos = npos) const;
  basic_string substr(size_type pos = 0, size_type n = npos) const;
  int compare(const basic_string &str) const noexcept;
  int compare(size_type pos1, size_type n1, const basic_string &str) const;
  int compare(size_type pos1, size_type n1, const basic_string &str,
              size_type pos2, size_type n2 = npos) const;
  int compare(const charT *s) const;
  int compare(size_type pos1, size_type n1, const charT *s) const;
  int compare(size_type pos1, size_type n1, const charT *s, size_type n2) const;
};

template <class charT, class traits, class Allocator>
basic_string<charT, traits, Allocator>
operator+(const basic_string<charT, traits, Allocator> &lhs,
          const basic_string<charT, traits, Allocator> &rhs);
template <class charT, class traits, class Allocator>
basic_string<charT, traits, Allocator>
operator+(const basic_string<charT, traits, Allocator> &lhs, const charT *rhs);
template <class charT, class traits, class Allocator>
basic_string<charT, traits, Allocator>
operator+(const charT *lhs, const basic_string<charT, traits, Allocator> &rhs);

template <class charT, class traits, class Allocator>
bool operator==(const basic_string<charT, traits, Allocator> &lhs,
                const basic_string<charT, traits, Allocator> &rhs) noexcept;
template <class charT, class traits, class Allocator>
bool operator==(const charT *lhs,
                const basic_string<charT, traits, Allocator> &rhs);
template <class charT, class traits, class Allocator>
bool operator==(const basic_string<charT, traits, Allocator> &lhs,
                const charT *rhs);
template <class charT, class traits, class Allocator>
bool operator!=(const basic_string<charT, traits, Allocator> &lhs,
                const basic_string<charT, traits, Allocator> &rhs) noexcept;
template <class charT, class traits, class Allocator>
bool operator!=(const charT *lhs,
                const basic_string<charT, traits, Allocator> &rhs);
template <class charT, class traits, class Allocator>
bool operator!=(const basic_string<charT, traits, Allocator> &lhs,
                const charT *rhs);
template <class charT, class traits, class Allocator>
bool operator<(const basic_string<charT, traits, Allocator> &lhs,
               const basic_string<charT, traits, Allocator> &rhs) noexcept;
template <class charT, class traits, class Allocator>
bool operator<(const basic_string<charT, traits, Allocator> &lhs,
               const charT *rhs);
template <class charT, class traits, class Allocator>
bool operator<(const charT *lhs,
               const basic_string<charT, traits, Allocator> &rhs);
template <class charT, class traits, class Allocator>
bool operator>(const basic_string<charT, traits, Allocator> &lhs,
               const basic_string<charT, traits, Allocator> &rhs) noexcept;
template <class charT, class traits, class Allocator>
bool operator>(const basic_string<charT, traits, Allocator> &lhs,
               const charT *rhs);
template <class charT, class traits, class Allocator>
bool operator>(const charT *lhs,
               const basic_string<charT, traits, Allocator> &rhs);
template <class charT, class traits, class Allocator>
bool operator<=(const basic_string<charT, traits, Allocator> &lhs,
                const basic_string<charT, traits, Allocator> &rhs) noexcept;
template <class charT, class traits, class Allocator>
bool operator<=(const basic_string<charT, traits, Allocator> &lhs,
                const charT *rhs);
template <class charT, class traits, class Allocator>
bool operator<=(const charT *lhs,
                const basic_string<charT, traits, Allocator> &rhs);
template <class charT, class traits, class Allocator>
bool operator>=(const basic_string<charT, traits, Allocator> &lhs,
                const basic_string<charT, traits, Allocator> &rhs) noexcept;
template <class charT, class traits, class Allocator>
bool operator>=(const basic_string<charT, traits, Allocator> &lhs,
                const charT *rhs);
template <class charT, class traits, class Allocator>
bool operator>=(const charT *lhs,
                const basic_string<charT, traits, Allocator> &rhs);

typedef basic_string<char> string;

typedef unsigned long size_t;
size_t strlen(const char *str);
char *strcpy(char *destination, const char *source);
char *strncpy(char *destination, const char *source, size_t num);

char *strcat(char *destination, const char *source);
char *strncat(char *destination, const char *source, size_t num);

int strcmp(const char *str1, const char *str2);
int strcoll(const char *str1, const char *str2);

int strncmp(const char *str1, const char *str2, size_t num);
size_t strxfrm(char *destination, const char *source, size_t num);

const char *strchr(const char *str, int character);
char *strchr(char *str, int character);

size_t strcspn(const char *str1, const char *str2);

const char *strpbrk(const char *str1, const char *str2);
char *strpbrk(char *str1, const char *str2);

const char *strrchr(const char *str, int character);
char *strrchr(char *str, int character);

size_t strspn(const char *str1, const char *str2);

const char *strstr(const char *str1, const char *str2);
char *strstr(char *str1, const char *str2);

char *strtok(char *str, const char *delimiters);

void *memcpy(void *dest, const void *src, size_t count);
void *memset(void *dest, int ch, size_t count);
void *memmove(void *dest, const void *src, size_t count);
int memcmp(const void *lhs, const void *rhs, size_t count);

errno_t memcpy_s(void *dest, rsize_t destsz, const void *src, rsize_t count);
errno_t memmove_s(void *dest, rsize_t destsz, const void *src, rsize_t count);

int stoi(const string &str, size_t *idx = 0, int base = 10);
long stol(const string &str, size_t *idx = 0, int base = 10);
unsigned long stoul(const string &str, size_t *idx = 0, int base = 10);
long long stoll(const string &str, size_t *idx = 0, int base = 10);
unsigned long long stoull(const string &str, size_t *idx = 0, int base = 10);
float stof(const string &str, size_t *idx = 0);
double stod(const string &str, size_t *idx = 0);
long double stold(const string &str, size_t *idx = 0);

std::string to_string(int value);
} // namespace std

std::errno_t memset_s(void *dest, rsize_t destsz, int ch, rsize_t count);
size_t strlen(const char *str);

#endif // _GHLIBCPP_STRING