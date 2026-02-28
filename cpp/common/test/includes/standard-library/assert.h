#ifndef _GHLIBCPP_ASSERT
#define _GHLIBCPP_ASSERT

#include <stdlib.h>
#include <stdio.h>

#define __assert(e, file, line) \
	((void)printf ("%s:%d: failed assertion `%s'\n", file, line, e), abort())

#define assert(e)  \
   { (__builtin_expect(!(e), 0) ? __assert (#e, __FILE__, __LINE__) : (void)0); }

#endif // _GHLIBCPP_ASSERT