#ifndef _GHLIBCPP_ANY
#define _GHLIBCPP_ANY
namespace std {

class any {
public:
  any();
  any(const any &);
  any(any &&);
  ~any();
  template <typename T> any(T &&);
};

} // namespace std

#endif // _GHLIBCPP_ANY
