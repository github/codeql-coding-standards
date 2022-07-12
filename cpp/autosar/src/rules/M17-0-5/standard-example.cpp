#include <setjmp.h>     
void f2();     
jmp_buf buf;     
void f1()
{
  if(!setjmp(buf)) // Non-compliant
  {
    f2();
  }
  else
  {
  } 
}
void f2()
{
  longjmp(buf, 10); // Non-compliant
}