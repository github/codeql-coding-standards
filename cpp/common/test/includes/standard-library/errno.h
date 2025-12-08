#ifndef _GHLIBCPP_ERRNO
#define _GHLIBCPP_ERRNO
int __errno;
#define errno __errno
#define EINVAL 22
#define ERANGE 34
#define EDOM 33
#endif // _GHLIBCPP_ERRNO