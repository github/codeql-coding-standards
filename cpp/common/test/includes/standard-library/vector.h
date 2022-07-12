#ifndef _GHLIBCPP_VECTOR
#define _GHLIBCPP_VECTOR
#include "iterator.h"
#include "string.h"

namespace std {

template <class T, class Allocator = std::allocator<T>> class vector {
public:
  typedef size_t size_type;
  typedef T value_type;
  typedef value_type &reference;
  typedef const value_type &const_reference;
  using difference_type = signed int;

  typedef __iterator<T> iterator;
  typedef __iterator<const T> const_iterator;

  iterator begin();
  iterator end();
  const_iterator cbegin();
  const_iterator cend();
  size_type size() const noexcept;
  void resize(size_type sz);
  void resize(size_type sz, const T &c);

  constexpr vector() : vector(Allocator()) {}
  constexpr explicit vector(const Allocator &);
  explicit vector(size_type n, const Allocator & = Allocator());
  vector(size_type n, const T &value, const Allocator & = Allocator());
  constexpr vector(const vector &x);
  constexpr vector(vector &&x);
  constexpr vector(const vector &, const Allocator &);
  constexpr vector(vector &&, const Allocator &);
  vector(initializer_list<T>, const Allocator & = Allocator());
  constexpr vector &operator=(const vector &x);
  constexpr vector &operator=(vector &&x);
  constexpr void clear() noexcept;
  bool empty() const noexcept;

  template <class... Args> void emplace_back(Args &&...args);
  void push_back(const T &x);
  void push_back(T &&x);
  void pop_back();
  template <class... Args>
  iterator emplace(const_iterator position, Args &&...args);
  iterator insert(const_iterator position, const T &x);
  iterator insert(const_iterator position, T &&x);
  iterator insert(const_iterator position, size_type n, const T &x);
  template <class InputIterator>
  iterator insert(const_iterator position, InputIterator first,
                  InputIterator last);
  iterator insert(const_iterator position, initializer_list<T> il);

  reference operator[](size_type n);
  const_reference operator[](size_type n) const;

  reference at(size_type n);
  reference front();
  const_reference front() const;
  reference back();
  const_reference back() const;
};
} // namespace std

#endif // _GHLIBCPP_VECTOR