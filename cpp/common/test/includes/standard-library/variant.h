#ifndef _GHLIBCPP_VARIANT
#define _GHLIBCPP_VARIANT

namespace std {

template<typename... Types>
class variant {
public:
    variant();
    variant(const variant&);
    variant(variant&&);
    template<typename T> variant(T&&);
    ~variant();
};

} // namespace std

#endif // _GHLIBCPP_VARIANT
