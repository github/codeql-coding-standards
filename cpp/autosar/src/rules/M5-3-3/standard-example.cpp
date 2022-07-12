// A.h 
class A
{
  public:
    A * operator & ( ); // Non-compliant
};
// f1.cc
class A;
void f ( A & a )
{
  &a;   // uses built-in operator &
}
// f2.cc
#include "A.h"
void f2 ( A & a )
{
  &a;   // use user-defined operator &
}