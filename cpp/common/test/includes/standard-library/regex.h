#ifndef _GHLIBCPP_REGEX
#define _GHLIBCPP_REGEX
namespace std {
template <typename CharT> class basic_regex {
public:
  basic_regex();
  basic_regex(const basic_regex &);
  basic_regex(basic_regex &&);
  basic_regex(const CharT *);
  ~basic_regex();
};
using regex = basic_regex<char>;
using wregex = basic_regex<wchar_t>;
} // namespace std
#endif // _GHLIBCPP_REGEX
