#define MACRO 2
#if MACRO != 1
#endif
#include <string> //COMPLIANT
#define CODEMACRO(x)                                                           \
  \ do { int g; }                                                              \
  while (0)

/*multi line comment here
 *
 *
 *
 */

#undef MACRO
#undef CODEMACRO

int g;

#include <exception> //NON_COMPLIANT
