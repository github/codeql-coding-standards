#ifndef _GHLIBCPP_ITERATOR
#define _GHLIBCPP_ITERATOR
#include "stddef.h"
#include "type_traits.h"

namespace std {

struct input_iterator_tag {};
struct forward_iterator_tag : public input_iterator_tag {};
struct bidirectional_iterator_tag : public forward_iterator_tag {};
struct random_access_iterator_tag : public bidirectional_iterator_tag {};

struct output_iterator_tag {};

template <class Iterator> struct iterator_traits {
  typedef typename Iterator::difference_type difference_type;
  typedef typename Iterator::value_type value_type;
  typedef typename Iterator::pointer pointer;
  typedef typename Iterator::reference reference;
  typedef typename Iterator::iterator_category iterator_category;
};

template <class T> struct iterator_traits<T *> {
  typedef ptrdiff_t difference_type;
  typedef T value_type;
  typedef T *pointer;
  typedef T &reference;
  typedef random_access_iterator_tag iterator_category;
};

template <class T> struct iterator_traits<const T *> {
  typedef ptrdiff_t difference_type;
  typedef T value_type;
  typedef const T *pointer;
  typedef const T &reference;
  typedef random_access_iterator_tag iterator_category;
};

template <class Category, class T, class Distance = ptrdiff_t,
          class Pointer = T *, class Reference = T &>
struct iterator {
  typedef T value_type;
  typedef Distance difference_type;
  typedef Pointer pointer;
  typedef Reference reference;
  typedef Category iterator_category;
};

// An "implementation" defined class that satisfies the [iterator.iterators]
// requirements
template <typename T>
struct __iterator : std::iterator<random_access_iterator_tag, T> {
  typedef T value_type;
  typedef ptrdiff_t difference_type;
  typedef T *pointer;
  typedef T &reference;
  typedef random_access_iterator_tag iterator_category;

  __iterator();
  __iterator(__iterator<remove_const_t<T>> const &other);

  __iterator &operator++();
  __iterator operator++(int);
  __iterator &operator--();
  __iterator operator--(int);
  bool operator==(__iterator other) const;
  bool operator!=(__iterator other) const;
  T &operator*() const;
  T *operator->() const;
  __iterator &operator+=(int);
  __iterator &operator-=(int);
  __iterator operator+(int);
  __iterator operator-(int);
  T &operator[](size_t);
};

template <typename T>
ptrdiff_t operator+(const __iterator<T> &, const __iterator<T> &);

template <typename T>
ptrdiff_t operator-(const __iterator<T> &, const __iterator<T> &);

template <typename T> struct iterator_traits<__iterator<T>>;

template <class Container> class back_insert_iterator {
protected:
  Container *container = nullptr;

public:
  using iterator_category = output_iterator_tag;
  using value_type = void;
  using difference_type = ptrdiff_t;
  using pointer = void;
  using reference = void;
  using container_type = Container;
  constexpr back_insert_iterator() noexcept = default;
  constexpr explicit back_insert_iterator(Container &x);
  back_insert_iterator &operator=(const typename Container::value_type &value);
  back_insert_iterator &operator=(typename Container::value_type &&value);
  back_insert_iterator &operator*();
  back_insert_iterator &operator++();
  back_insert_iterator operator++(int);
};

template <class Container>
constexpr back_insert_iterator<Container> back_inserter(Container &x) {
  return back_insert_iterator<Container>(x);
}

template <class Container> class front_insert_iterator {
protected:
  Container *container = nullptr;

public:
  using iterator_category = output_iterator_tag;
  using value_type = void;
  using difference_type = ptrdiff_t;
  using pointer = void;
  using reference = void;
  using container_type = Container;
  constexpr front_insert_iterator() noexcept = default;
  constexpr explicit front_insert_iterator(Container &x);
  constexpr front_insert_iterator &
  operator=(const typename Container::value_type &value);
  constexpr front_insert_iterator &
  operator=(typename Container::value_type &&value);
  constexpr front_insert_iterator &operator*();
  constexpr front_insert_iterator &operator++();
  constexpr front_insert_iterator operator++(int);
};
template <class Container>
constexpr front_insert_iterator<Container> front_inserter(Container &x) {
  return front_insert_iterator<Container>(x);
}

template <class Container>
class insert_iterator
    : public iterator<output_iterator_tag, void, void, void, void> {
protected:
  Container *container;
  typename Container::iterator iter;

public:
  typedef Container container_type;
  insert_iterator(Container &x, typename Container::iterator i);
  insert_iterator<Container> &
  operator=(const typename Container::value_type &value);
  insert_iterator<Container> &operator=(typename Container::value_type &&value);
  insert_iterator<Container> &operator*();
  insert_iterator<Container> &operator++();
  insert_iterator<Container> &operator++(int);
};

template <class Container>
insert_iterator<Container> inserter(Container &x,
                                    typename Container::iterator i);
} // namespace std
#endif _GHLIBCPP_ITERATOR