#ifndef _GHLIBCPP_CSTRING
#define _GHLIBCPP_CSTRING
typedef unsigned long size_t;
namespace std {
void *memcpy(void *, const void *, size_t);
size_t strlen(const char *);
} // namespace std
#endif // _GHLIBCPP_CSTRING
