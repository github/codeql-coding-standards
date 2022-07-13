#include <cstddef>
struct A
{  
  int32_t i;
};
void f1()
{ 
  offsetof(A, i); // Non-compliant
}