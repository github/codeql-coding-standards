#include <cstddef>
void f1 ( int32_t   );
void f2 ( int32_t * );
void f3 ( )
{ 
  f1 ( 0 ); // Compliant
  f2 ( 0 ); // Non-compliant, 0 used as the null pointer constant
}