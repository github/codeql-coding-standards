#ifndef _GHLIBCPP_FILESYSTEM
#define _GHLIBCPP_FILESYSTEM

namespace std {
namespace filesystem {

class path {
public:
    path();
    path(const path&);
    path(path&&);
    path(const char*);

    path operator/(const path&) const;
};

} // namespace filesystem
} // namespace std

#endif // _GHLIBCPP_FILESYSTEM
