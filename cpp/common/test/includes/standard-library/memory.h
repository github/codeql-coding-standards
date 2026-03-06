#ifndef _GHLIBCPP_MEMORY
#define _GHLIBCPP_MEMORY
#include "exception.h"
#include "iterator.h"
#include "stddef.h"
#include "utility.h"

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
  bool unique() const noexcept;

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
  // deprecated in C++17:
  using pointer = T1 *;
  using const_pointer = const T1 *;
  using reference = T1 &;
  using const_reference = const T1 &;
  template <class T2> struct rebind {
    using other = allocator<T2>;
  };

  constexpr allocator() noexcept = default;
  constexpr allocator(const allocator &) noexcept = default;

  template <typename T2> constexpr allocator(const allocator<T2> &) noexcept;

  ~allocator() = default;

  T1 *allocate(std::size_t);
  T1 *allocate(std::size_t, const void *);
  void deallocate(T1 *, std::size_t);
  // deprecated in C++17:
  pointer address(reference r) const noexcept;
  const_pointer address(const_reference r) const noexcept;
  size_type max_size() const noexcept;
  template <class U, class... Args> void construct(U *p, Args &&...args);
  template <class U> void destroy(U *p);
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

// uninitialized_default_construct
template <class T1>
void uninitialized_default_construct(T1, T1);

template <class T1, class T2>
void uninitialized_default_construct(T1&&, T2, T2);

// uninitialized_default_construct_n
template <class T1, class T2>
T1 uninitialized_default_construct_n(T1, T2);

template <class T1, class T2, class T3>
T2 uninitialized_default_construct_n(T1&&, T2, T3);

// uninitialized_value_construct
template <class T1>
void uninitialized_value_construct(T1, T1);

template <class T1, class T2>
void uninitialized_value_construct(T1&&, T2, T2);

// uninitialized_value_construct_n
template <class T1, class T2>
T1 uninitialized_value_construct_n(T1, T2);

template <class T1, class T2, class T3>
T2 uninitialized_value_construct_n(T1&&, T2, T3);

// uninitialized_copy
template <class T1, class T2>
T2 uninitialized_copy(T1, T1, T2);

template <class T1, class T2, class T3>
T3 uninitialized_copy(T1&&, T2, T2, T3);

// uninitialized_copy_n
template <class T1, class T2, class T3>
T3 uninitialized_copy_n(T1, T2, T3);

template <class T1, class T2, class T3, class T4>
T4 uninitialized_copy_n(T1&&, T2, T3, T4);

// uninitialized_move
template <class T1, class T2>
T2 uninitialized_move(T1, T1, T2);

template <class T1, class T2, class T3>
T3 uninitialized_move(T1&&, T2, T2, T3);

// uninitialized_move_n
template <class T1, class T2, class T3>
pair<T1, T3> uninitialized_move_n(T1, T2, T3);

template <class T1, class T2, class T3, class T4>
pair<T2, T4> uninitialized_move_n(T1&&, T2, T3, T4);

// uninitialized_fill
template <class T1, class T2>
void uninitialized_fill(T1, T1, const T2&);

template <class T1, class T2, class T3>
void uninitialized_fill(T1&&, T2, T2, const T3&);

// uninitialized_fill_n
template <class T1, class T2, class T3>
T1 uninitialized_fill_n(T1, T2, const T3&);

template <class T1, class T2, class T3, class T4>
T2 uninitialized_fill_n(T1&&, T2, T3, const T4&);

// destroy_at
template <class T1>
void destroy_at(T1*);

// destroy
template <class T1>
void destroy(T1, T1);

template <class T1, class T2>
void destroy(T1&&, T2, T2);

// destroy_n
template <class T1, class T2>
T1 destroy_n(T1, T2);

template <class T1, class T2, class T3>
T2 destroy_n(T1&&, T2, T3);

// launder
template <class T1>
constexpr T1* launder(T1*) noexcept;

// get_temporary_buffer / return_temporary_buffer (deprecated in C++17)
template <class T>
pair<T *, ptrdiff_t> get_temporary_buffer(ptrdiff_t n) noexcept;

template <class T>
void return_temporary_buffer(T *p);

// raw_storage_iterator (deprecated in C++17)
template <class OutputIterator, class T>
class raw_storage_iterator {
public:
  using iterator_category = output_iterator_tag;
  using value_type = void;
  using difference_type = void;
  using pointer = void;
  using reference = void;
  explicit raw_storage_iterator(OutputIterator x);
  raw_storage_iterator &operator*();
  raw_storage_iterator &operator=(const T &element);
  raw_storage_iterator &operator=(T &&element);
  raw_storage_iterator &operator++();
  raw_storage_iterator operator++(int);
  OutputIterator base() const;
};

} // namespace std

#endif // _GHLIBCPP_MEMORY
