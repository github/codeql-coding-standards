
#include <string.h>
#define MACROFUNCTION(X) strlen(X)

void func(const char *src) {
  char *dest;

  MACROFUNCTION(
#if NOTDEFINEDMACRO // NON_COMPLIANT
      "longstringtest!test!"
#else  // NON_COMPLIANT
      "shortstring"
#endif // NON_COMPLIANT
  );

  MACROFUNCTION("alright"); // COMPLIANT
  memcpy(dest, src, 12);    // COMPLIANT

  memcpy(dest, src,
#ifdef SOMEMACRO // NON_COMPLIANT
         12
#else  // NON_COMPLIANT
         24
#endif // NON_COMPLIANT
  );

#if TEST // COMPLIANT[FALSE_POSITIVE]
#endif   // COMPLIANT[FALSE_POSITIVE]
}