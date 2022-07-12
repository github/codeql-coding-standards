// f1.h
void foo(char_t a);
namespace NS1
{ 
  void foo( int32_t a );
}
inline void bar ( )
{
  foo(0);
}
// f2.h
namespace NS1
{
}
using namespace NS1;
// f1.cc
#include "f1.h"
#include "f2.h"
int32_t m1()
{
  bar(); // bar calls foo(char_t);
}
// f2.cc
#include "f2.h"
#include "f1.h"
void m2()
{ 
  bar(); // bar calls foo(int32_t);
}