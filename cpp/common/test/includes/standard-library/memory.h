#ifndef _GHLIBCPP_MEMORY
#define _GHLIBCPP_MEMORY
#include "exception.h"
#include "stddef.h"

namespace std {

template <class T> T *addressof(T &arg) noexcept;

template <typename T> struct default_delete {
  void operator()(T *ptr) { delete ptr; }
};

template <typename T> struct default_delete<T[]> {
  void operator()(T *ptr) { delete[] ptr; }
};

template <typename T, typename Deleter = std::default_delete<T>>
class unique_ptr {
public:
  typedef T *pointer;
  unique_ptr() {}
  unique_ptr(T *ptr) {}
  unique_ptr(const unique_ptr<T> &t) = delete;
  unique_ptr(unique_ptr<T> &&t) {}
  unique_ptr(pointer p, Deleter d) noexcept {}
  ~unique_ptr() {}
  T &operator*() const { return *ptr; }
  T *operator->() const noexcept { return ptr; }
  T *get() const noexcept { return ptr; }
  T *release() { return ptr; }
  void reset(pointer __p = pointer()) {}
  T *get() { return ptr; }
  unique_ptr<T> &operator=(const unique_ptr &) = delete;
  unique_ptr<T> &operator=(unique_ptr &&) { return *this; }
  template <typename T> unique_ptr &operator=(unique_ptr<T> &&) {
    return *this;
  }

private:
  T *ptr;
};

template <class T, class D> class unique_ptr<T[], D> {
public:
  typedef T *pointer;
  typedef T element_type;
  typedef D deleter_type;
  constexpr unique_ptr() noexcept;
  explicit unique_ptr(pointer p) noexcept;
  unique_ptr(pointer p, deleter_type) noexcept;
  unique_ptr(unique_ptr &&u) noexcept;
  constexpr unique_ptr(nullptr_t) noexcept : unique_ptr() {}
  ~unique_ptr();
  unique_ptr &operator=(unique_ptr &&u) noexcept;
  unique_ptr &operator=(nullptr_t) noexcept;
  T &operator[](size_t i) const;
  pointer get() const noexcept;
  explicit operator bool() const noexcept;

  pointer release() noexcept {
    pointer __p = get();
    _M_p = pointer();
    return __p;
  }
  void reset(pointer p = pointer()) noexcept;
  void reset(nullptr_t) noexcept;
  template <class U> void reset(U) = delete;
  void swap(unique_ptr &u) noexcept;
  unique_ptr(const unique_ptr &) = delete;
  unique_ptr &operator=(const unique_ptr &) = delete;

private:
  pointer _M_p;
};

template <class T, class... Args> unique_ptr<T> make_unique(Args &&...args);
template <class T> unique_ptr<T> make_unique(size_t n);

template <typename T> class __shared_ptr {
public:
  void reset() noexcept;
  template <class Y> void reset(Y *p);
  template <class Y, class D> void reset(Y *p, D d);
  template <class Y, class D, class A> void reset(Y *p, D d, A a);

  long use_count() const noexcept;
  T *get() const noexcept;
};

template <typename T> class shared_ptr : public __shared_ptr<T> {
public:
  shared_ptr();
  shared_ptr(T *ptr);
  shared_ptr(const shared_ptr<T> &r) noexcept;
  template <class Y> shared_ptr(const shared_ptr<Y> &r) noexcept;
  template <class Y> shared_ptr(const shared_ptr<Y> &r, T *p) noexcept;
  shared_ptr(shared_ptr<T> &&r) noexcept;
  template <class Y> shared_ptr(shared_ptr<Y> &&r) noexcept;
  template <class D> shared_ptr(T *p, D d);
  shared_ptr(unique_ptr<T> &&t) {}
  ~shared_ptr() {}
  T &operator*() const noexcept;
  T *operator->() const noexcept;

  shared_ptr<T> &operator=(const shared_ptr &) {}
  shared_ptr<T> &operator=(shared_ptr &&) { return *this; }
  template <typename S> shared_ptr &operator=(shared_ptr<T> &&) {
    return *this;
  }

private:
  T *ptr;
};

template <class T, class... Args> shared_ptr<T> make_shared(Args &&...args);
template <class T> shared_ptr<T> make_shared(size_t N);

template <class X> class auto_ptr {
public:
  explicit auto_ptr(X *p = 0) throw();
};

class bad_alloc : public exception {
public:
  bad_alloc() noexcept;
  bad_alloc(const bad_alloc &) noexcept;
  bad_alloc &operator=(const bad_alloc &) noexcept;
  virtual const char *what() const noexcept;
};

template <typename T1> struct allocator {
  using value_type = T1;
  using size_type = std::size_t;
  using difference_type = std::ptrdiff_t;

  constexpr allocator() noexcept = default;
  constexpr allocator(const allocator &) noexcept = default;

  template <typename T2> constexpr allocator(const allocator<T2> &) noexcept;

  ~allocator() = default;

  T1 *allocate(std::size_t);
  void deallocate(T1 *, std::size_t);
};

template <> struct allocator<void> {
  using value_type = void;
};

template <typename T1> struct allocator_traits {
  using allocator_type = T1;
  using value_type = typename T1::value_type;
  using pointer = value_type *;
  using const_pointer = const value_type *;
  using void_pointer = void *;
  using const_void_pointer = const void *;
  using size_type = typename T1::size_type;
  using difference_type = typename T1::difference_type;

  template <typename T2> using rebind_alloc = allocator<T2>;

  static pointer allocate(T1 &, size_type);
  static pointer allocate(T1 &, size_type, const_void_pointer);
  static void deallocate(T1 &, pointer, size_type);
};
} // namespace std

#endif // _GHLIBCPP_MEMORY
