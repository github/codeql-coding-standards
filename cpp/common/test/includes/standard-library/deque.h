#ifndef _GHLIBCPP_DEQUE
#define _GHLIBCPP_DEQUE
#include "iterator.h"
#include "string.h"

namespace std {
template <class T, class Allocator = std::allocator<T>> class deque {
public:
  typedef size_t size_type;
  typedef T value_type;
  typedef value_type &reference;
  typedef const value_type &const_reference;

  typedef __iterator<T> iterator;
  typedef __iterator<T> const_iterator;

  iterator begin();
  iterator end();
  iterator insert(const_iterator pos, const T &x);
  iterator insert(const_iterator pos, T &&x);
  iterator insert(const_iterator pos, size_type n, const T &x);
  template <class InputIterator>
  iterator insert(const_iterator pos, InputIterator first, InputIterator last);
  iterator insert(const_iterator pos, initializer_list<T>);
  bool empty() const;

  template <class... Args> void emplace_front(Args &&...args);
  template <class... Args> void emplace_back(Args &&...args);
  template <class... Args> iterator emplace(const_iterator pos, Args &&...args);

  void push_back(const T &x);
  void push_back(T &&x);
  void pop_back();
};
} // namespace std

#endif // _GHLIBCPP_DEQUE