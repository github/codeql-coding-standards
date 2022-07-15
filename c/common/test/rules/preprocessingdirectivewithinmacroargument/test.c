#include <string.h>
#define MACROFUNCTION(X) strlen(X)

void f() {
  MACROFUNCTION(
#if NOTDEFINEDMACRO // NON_COMPLIANT
      "longstringtest!test!"
#else  // NON_COMPLIANT
      "shortstring"
#endif // NON_COMPLIANT
  );

  MACROFUNCTION("alright"); // COMPLIANT
}