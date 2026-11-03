#include <stdlib.h>

#undef assert
#ifdef NDEBUG
#define assert(value) ((void)0)
#else
#define assert(value) ((value) ? (void)0 : abort())
#endif