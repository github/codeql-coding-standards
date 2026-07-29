#ifndef _GHLIBCPP_STACK
#define _GHLIBCPP_STACK

namespace std {

template<typename T>
class stack {
public:
    stack();
    stack(const stack&);
    stack(stack&&);
    ~stack();
};

} // namespace std

#endif // _GHLIBCPP_STACK
