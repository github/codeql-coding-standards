#include <cstddef>
void f1 ( int32_t   );
void f2 ( int32_t * );
void f3 ( )
{
  f1 ( NULL ); // Not-compliant, NULL used as an integer
  f2 ( NULL ); // Compliant
}