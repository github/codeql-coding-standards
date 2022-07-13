#ifndef _GHLIBCPP_STDDEF
#define _GHLIBCPP_STDDEF
typedef unsigned long size_t;
typedef size_t rsize_t;
namespace std {
typedef unsigned long size_t;
typedef struct { // equivalent to that provided by clang and gcc
  __attribute__((
      __aligned__(__alignof__(long long)))) long long __dummy_field_1;
  __attribute__((
      __aligned__(__alignof__(long double)))) long double __dummy_field_2;
} max_align_t;
typedef long ptrdiff_t;
using nullptr_t = decltype(nullptr);
using size_t = decltype(sizeof(char));
} // namespace std

#define offsetof(t, d) __builtin_offsetof(t, d) /*implementation-defined*/

// namespace std
#endif // _GHLIBCPP_STDDEF