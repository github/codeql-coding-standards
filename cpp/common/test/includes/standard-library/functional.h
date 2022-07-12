#ifndef _GHLIBCPP_FUNCTIONAL
#define _GHLIBCPP_FUNCTIONAL

namespace std {
typedef unsigned long size_t;

namespace placeholders {

template <int _Np> struct __ph {};
extern const __ph<1> _1;
extern const __ph<2> _2;

} // namespace placeholders
template <class Fn, class... Args> class binder {
public:
  template <class TFn, class... TArgs>
  constexpr binder(TFn &&f, TArgs &&...args) noexcept {}

  template <class... CallArgs>
  constexpr decltype(auto) operator()(CallArgs &&...args);
};

template <typename ArgumentType, typename ResultType> struct unary_function {};
template <class Arg1, class Arg2, class Result> struct binary_function {
  typedef Arg1 first_argument_type;
  typedef Arg2 second_argument_type;
  typedef Result result_type;
};

template <class Fn> class binder1st {
protected:
  Fn op;
};

template <class Fn> class binder2nd {
protected:
  Fn op;
};

template <class F, class Args> binder<F, Args> bind(F &&f, Args &&args, ...);
template <class F, class T> binder1st<F> bind1st(const F &f, const T &x);
template <class F, class T> binder2nd<F> bind2nd(const F &f, const T &x);

template <class T> class reference_wrapper {
  reference_wrapper(T &ref) : ref(addressof(ref)) {}
  reference_wrapper(T &&ref) = delete;

  operator T &() const { return *ref; }

private:
  T *ref;
};

template <class T> reference_wrapper<T> ref(T &t) noexcept;
template <class T> void ref(const T &&t) = delete;
template <class T> reference_wrapper<T> ref(reference_wrapper<T> t) noexcept;

template <class Ty> struct hash { size_t operator()(Ty val) const; };

template <class Arg, class Result>
class pointer_to_unary_function : public unary_function<Arg, Result> {
public:
  explicit pointer_to_unary_function(Result (*f)(Arg)) : pfunc(f) {}
  Result operator()(Arg x) const { return pfunc(x); }
};

template <class Arg1, class Arg2, class Result>
class pointer_to_binary_function : public binary_function<Arg1, Arg2, Result> {
public:
  explicit pointer_to_binary_function(Result (*f)(Arg1, Arg2)) : pfunc(f) {}
  Result operator()(Arg1 x, Arg2 y) const { return pfunc(x, y); }
};

template <class Arg, class Result>
pointer_to_unary_function<Arg, Result> ptr_fun(Result (*f)(Arg));
template <class Arg1, class Arg2, class Result>
pointer_to_binary_function<Arg1, Arg2, Result> ptr_fun(Result (*f)(Arg1, Arg2));

template <class T> struct equal_to {
  bool operator()(const T &x, const T &y) const { return x == y; }
  typedef T first_argument_type;
  typedef T second_argument_type;
  typedef bool result_type;
};

template <class> class function;
template <class R, class... Args> class function<R(Args...)> {
public:
  function();
  template <class F> function(F &&);
  template <class F> function &operator=(F &&);
};
} // namespace std
#endif