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

  template <typename T1>
  struct allocator {
    using value_type = T1;
    using size_type = std::size_t;
    using difference_type = std::ptrdiff_t;
    using propagate_on_container_move_assignment = std::true_type;
    using is_always_equal = std::true_type;

    using pointer = T1*; // deprecated since C++17
    using const_pointer = const T1*; // deprecated since C++17
    using reference = T1&; // deprecated since C++17
    using const_reference = const T1&; // deprecated since C++17

    // deprecated since C++17
    template <typename T2>
    struct rebind {
      using other = allocator<T2>;
    };

    constexpr allocator() noexcept = default;
    constexpr allocator(const allocator&) noexcept = default;

    template <typename T2>
    constexpr allocator(const allocator<T2>&) noexcept;

    ~allocator() = default;

    allocator& operator=(const allocator&) = default;

    T1* allocate(std::size_t);
    void deallocate(T1*, std::size_t);

    T1* address(T1&) const noexcept; // deprecated since C++17
    const T1* address(const T1&) const noexcept; // deprecated since C++17
    std::size_t max_size() const noexcept; // deprecated since C++17

    // deprecated since C++17
    template <typename T2, typename... T3>
    void construct(T2*, T3&&...);

    // deprecated since C++17
    template <typename T2>
    void destroy(T2*);
  };

  // deprecated since C++17
  template <>
  struct allocator<void> {
    using value_type = void;
    using size_type = std::size_t;
    using difference_type = std::ptrdiff_t;
    using propagate_on_container_move_assignment = std::true_type;
    using is_always_equal = std::true_type;

    // deprecated since C++17
    template <typename T1>
    struct rebind {
      using other = allocator<T1>;
    };
  };

  template <typename T1, typename T2>
  constexpr bool operator==(const allocator<T1>&, const allocator<T2>&) noexcept;

  template <typename T1, typename T2>
  constexpr bool operator!=(const allocator<T1>&, const allocator<T2>&) noexcept;

  namespace detail {

    template <typename T1, typename = void>
    struct has_pointer : std::false_type {};

    template <typename T1>
    struct has_pointer<T1, std::void_t<typename T1::pointer>> : std::true_type {};

    template <typename T1, typename = void>
    struct has_const_pointer : std::false_type {};

    template <typename T1>
    struct has_const_pointer<T1, std::void_t<typename T1::const_pointer>> : std::true_type {};

    template <typename T1, typename = void>
    struct has_void_pointer : std::false_type {};

    template <typename T1>
    struct has_void_pointer<T1, std::void_t<typename T1::void_pointer>> : std::true_type {};

    template <typename T1, typename = void>
    struct has_const_void_pointer : std::false_type {};

    template <typename T1>
    struct has_const_void_pointer<T1, std::void_t<typename T1::const_void_pointer>> : std::true_type {};

    template <typename T1, typename = void>
    struct has_difference_type : std::false_type {};

    template <typename T1>
    struct has_difference_type<T1, std::void_t<typename T1::difference_type>> : std::true_type {};

    template <typename T1, typename = void>
    struct has_size_type : std::false_type {};

    template <typename T1>
    struct has_size_type<T1, std::void_t<typename T1::size_type>> : std::true_type {};

    template <typename T1, typename = void>
    struct has_propagate_on_container_copy_assignment : std::false_type {};

    template <typename T1>
    struct has_propagate_on_container_copy_assignment<T1,
                                                      std::void_t<typename T1::propagate_on_container_copy_assignment>> : std::true_type {};

    template <typename T1, typename = void>
    struct has_propagate_on_container_move_assignment : std::false_type {};

    template <typename T1>
    struct has_propagate_on_container_move_assignment<T1,
                                                      std::void_t<typename T1::propagate_on_container_move_assignment>> : std::true_type {};

    template <typename T1, typename = void>
    struct has_propagate_on_container_swap : std::false_type {};

    template <typename T1>
    struct has_propagate_on_container_swap<T1,
                                           std::void_t<typename T1::propagate_on_container_swap>> : std::true_type {};

    template <typename T1, typename = void>
    struct has_is_always_equal : std::false_type {};

    template <typename T1>
    struct has_is_always_equal<T1, std::void_t<typename T1::is_always_equal>> : std::true_type {};

    template <typename T1, typename T2, typename = void>
    struct has_rebind_alloc : std::false_type {};

    template <typename T1, typename T2>
    struct has_rebind_alloc<T1, T2,
                            std::void_t<typename T1::template rebind<T2>::other>> : std::true_type {};

    template <typename T1, typename T2, bool = has_rebind_alloc<T1, T2>::value>
    struct rebind_alloc_helper;

    template <typename T1, typename T2>
    struct rebind_alloc_helper<T1, T2, true> {
      using type = typename T1::template rebind<T2>::other;
    };

    template <template <typename, typename...> class T1, typename T2, typename T3, typename... T4>
    struct rebind_alloc_helper<T1<T2, T4...>, T3, false> {
      using type = T1<T3, T4...>;
    };

  }

  template <typename T1>
  struct allocator_traits {
    using allocator_type = T1;
    using value_type = typename T1::value_type;

    using pointer = typename std::conditional<
      detail::has_pointer<T1>::value,
      typename T1::pointer,
      value_type*
      >::type;

    using const_pointer = typename std::conditional<
      detail::has_const_pointer<T1>::value,
      typename T1::const_pointer,
      typename std::pointer_traits<pointer>::template rebind<const value_type>
      >::type;

    using void_pointer = typename std::conditional<
      detail::has_void_pointer<T1>::value,
      typename T1::void_pointer,
      typename std::pointer_traits<pointer>::template rebind<void>
      >::type;

    using const_void_pointer = typename std::conditional<
      detail::has_const_void_pointer<T1>::value,
      typename T1::const_void_pointer,
      typename std::pointer_traits<pointer>::template rebind<const void>
      >::type;

    using difference_type = typename std::conditional<
      detail::has_difference_type<T1>::value,
      typename T1::difference_type,
      typename std::pointer_traits<pointer>::difference_type
      >::type;

    using size_type = typename std::conditional<
      detail::has_size_type<T1>::value,
      typename T1::size_type,
      typename std::make_unsigned<difference_type>::type
      >::type;

    using propagate_on_container_copy_assignment = typename std::conditional<
      detail::has_propagate_on_container_copy_assignment<T1>::value,
      typename T1::propagate_on_container_copy_assignment,
      std::false_type
      >::type;

    using propagate_on_container_move_assignment = typename std::conditional<
      detail::has_propagate_on_container_move_assignment<T1>::value,
      typename T1::propagate_on_container_move_assignment,
      std::false_type
      >::type;

    using propagate_on_container_swap = typename std::conditional<
      detail::has_propagate_on_container_swap<T1>::value,
      typename T1::propagate_on_container_swap,
      std::false_type
      >::type;

    using is_always_equal = typename std::conditional<
      detail::has_is_always_equal<T1>::value,
      typename T1::is_always_equal,
      typename std::is_empty<T1>::type
      >::type;

    template <typename T2>
    using rebind_alloc = typename detail::rebind_alloc_helper<T1, T2>::type;

    template <typename T2>
    using rebind_traits = allocator_traits<rebind_alloc<T2>>;

    static pointer allocate(T1&, size_type);
    static pointer allocate(T1&, size_type, const_void_pointer);
    static void deallocate(T1&, pointer, size_type);

    template <typename T2, typename... T3>
    static void construct(T1&, T2*, T3&&...);

    template <typename T2>
    static void destroy(T1&, T2*);

    static size_type max_size(const T1&) noexcept;
    static T1 select_on_container_copy_construction(const T1&);
  };

  template <typename T1, typename... T2>
  class scoped_allocator_adaptor : public T1 {
  public:
    using outer_allocator_type = T1;
    using inner_allocator_type = typename std::conditional<
      sizeof...(T2) == 0,
      scoped_allocator_adaptor<T1>,
      scoped_allocator_adaptor<T2...>
      >::type;

    using value_type = typename allocator_traits<T1>::value_type;
    using size_type = typename allocator_traits<T1>::size_type;
    using difference_type = typename allocator_traits<T1>::difference_type;
    using pointer = typename allocator_traits<T1>::pointer;
    using const_pointer = typename allocator_traits<T1>::const_pointer;
    using void_pointer = typename allocator_traits<T1>::void_pointer;
    using const_void_pointer = typename allocator_traits<T1>::const_void_pointer;

    using propagate_on_container_copy_assignment = typename std::conditional<
      allocator_traits<T1>::propagate_on_container_copy_assignment::value ||
      (allocator_traits<T2>::propagate_on_container_copy_assignment::value || ...),
      std::true_type,
      std::false_type
      >::type;

    using propagate_on_container_move_assignment = typename std::conditional<
      allocator_traits<T1>::propagate_on_container_move_assignment::value ||
      (allocator_traits<T2>::propagate_on_container_move_assignment::value || ...),
      std::true_type,
      std::false_type
      >::type;

    using propagate_on_container_swap = typename std::conditional<
      allocator_traits<T1>::propagate_on_container_swap::value ||
      (allocator_traits<T2>::propagate_on_container_swap::value || ...),
      std::true_type,
      std::false_type
      >::type;

    using is_always_equal = typename std::conditional<
      allocator_traits<T1>::is_always_equal::value &&
      (allocator_traits<T2>::is_always_equal::value && ...),
      std::true_type,
      std::false_type
      >::type;

    template <typename T3>
    struct rebind {
      using other = scoped_allocator_adaptor<
        typename allocator_traits<T1>::template rebind_alloc<T3>,
        T2...
        >;
    };

    scoped_allocator_adaptor();

    template <typename T3>
    scoped_allocator_adaptor(T3&&, const T2&...) noexcept;

    scoped_allocator_adaptor(const scoped_allocator_adaptor&) noexcept;
    scoped_allocator_adaptor(scoped_allocator_adaptor&&) noexcept;

    template <typename T3, typename... T4>
    scoped_allocator_adaptor(const scoped_allocator_adaptor<T3, T4...>&) noexcept;

    template <typename T3, typename... T4>
    scoped_allocator_adaptor(scoped_allocator_adaptor<T3, T4...>&&) noexcept;

    scoped_allocator_adaptor& operator=(const scoped_allocator_adaptor&) = default;
    scoped_allocator_adaptor& operator=(scoped_allocator_adaptor&&) = default;

    ~scoped_allocator_adaptor() = default;

    inner_allocator_type& inner_allocator() noexcept;
    const inner_allocator_type& inner_allocator() const noexcept;

    outer_allocator_type& outer_allocator() noexcept;
    const outer_allocator_type& outer_allocator() const noexcept;

    pointer allocate(size_type);
    pointer allocate(size_type, const_void_pointer);
    void deallocate(pointer, size_type);

    size_type max_size() const;

    template <typename T3, typename... T4>
    void construct(T3*, T4&&...);

    template <typename T3, typename T4, typename... T5, typename... T6>
    void construct(std::pair<T3, T4>*,
                   std::piecewise_construct_t,
                   std::tuple<T5...>,
                   std::tuple<T6...>);

    template <typename T3, typename T4>
    void construct(std::pair<T3, T4>*);

    template <typename T3, typename T4, typename T5, typename T6>
    void construct(std::pair<T3, T4>*, T5&&, T6&&);

    template <typename T3, typename T4, typename T5, typename T6>
    void construct(std::pair<T3, T4>*, const std::pair<T5, T6>&);

    template <typename T3, typename T4, typename T5, typename T6>
    void construct(std::pair<T3, T4>*, std::pair<T5, T6>&&);

    template <typename T3>
    void destroy(T3*);

    scoped_allocator_adaptor select_on_container_copy_construction() const;

  private:
    inner_allocator_type inner_;
  };

  template <typename T1, typename... T2, typename T3, typename... T4>
  bool operator==(const scoped_allocator_adaptor<T1, T2...>&,
                  const scoped_allocator_adaptor<T3, T4...>&) noexcept;

  template <typename T1, typename... T2, typename T3, typename... T4>
  bool operator!=(const scoped_allocator_adaptor<T1, T2...>&,
                  const scoped_allocator_adaptor<T3, T4...>&) noexcept;

} // namespace std

#endif // _GHLIBCPP_MEMORY
