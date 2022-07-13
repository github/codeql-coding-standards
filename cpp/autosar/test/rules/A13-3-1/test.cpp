/* A function that contains "forwarding reference" as
its argument shall not be overloaded */

namespace std {

template <typename T> struct remove_cv { typedef T value; };
template <typename T> using remove_cv_t = typename remove_cv<T>::value;

template <typename T> struct remove_reference { typedef T value; };
template <typename T>
using remove_reference_t = typename remove_reference<T>::value;

template <bool B, class T = void> struct enable_if {};

template <class T> struct enable_if<true, T> { typedef T type; };

template <bool B, class T = void>
using enable_if_t = typename enable_if<B, T>::type;

template <class T, class U> struct is_same { static const bool value = false; };
template <class T> struct is_same<T, T> { static const bool value = true; };
} // namespace std

void F1(int &&t) {} // NON_COMPLIANT - overloading a function with
// forwarding reference

template <class T> void F1(T &&x) {} //

// for (auto&& x: f()) {
//   // x is a forwarding reference; this is the safest way to use range for
//   loops
// }

// template<class T>
// int f(const T&& x); // x is not a forwarding reference: const T is not
// cv-unqualified

// int f(int&& x);

class A {
public:
  // COMPLIANT by exception, constrained to not match copy/move ctors
  template <
      typename T,
      std::enable_if_t<!std::is_same<
          std::remove_cv_t<std::remove_reference_t<T>>, A>::value> * = nullptr>
  A(T &&value);

  A(A const &);
  A(A &&);
};

A a(1);
A b(a);
// template<class T> struct A {
//     template<class U>
//     A(T&& x, U&& y, int* p); // x is not a forwarding reference: T is not a
//                              // type template parameter of the constructor,
//                              // but y is a
// forwarding reference
void F1(int &) = delete; // COMPLIANT by exception

struct B {
  template <typename T,
            std::enable_if_t<!std::is_same<T, B>::value> * = nullptr>
  B(T &&value) {}
};

int main() {}