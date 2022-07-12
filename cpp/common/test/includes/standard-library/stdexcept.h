#ifndef _GHLIBCPP_STDEXCEPT
#define _GHLIBCPP_STDEXCEPT
#include "exception.h"
#include "string.h"

namespace std {
class logic_error : public exception {
public:
  explicit logic_error(const string &what_arg);
  explicit logic_error(const char *what_arg);
};

class runtime_error : public exception {
public:
  explicit runtime_error(const string &what_arg);
  explicit runtime_error(const char *what_arg);
};

class nested_exception {
public:
  nested_exception() noexcept;
  nested_exception(const nested_exception &) noexcept = default;
  nested_exception &operator=(const nested_exception &) noexcept = default;
  virtual ~nested_exception() = default;
  [[noreturn]] void rethrow_nested() const;
};

template <typename T> [[noreturn]] void throw_with_nested(T &&t);
template <typename E> void rethrow_if_nested(E const &e);

} // namespace std
#endif // _GHLIBCPP_STDEXCEPT