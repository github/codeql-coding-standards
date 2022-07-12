//% $Id: A4-10-1.cpp 298086 2017-11-24 11:13:27Z michal.szczepankiewicz $
#include <cstddef>
#include <cstdint>

void F1(std::int32_t);
void F2(std::int32_t*);
void F3()
{
  F1(0);// Compliant
  F1(NULL); // Non-compliant - NULL used as an integer,
  // compilable
  // f1(nullptr); // Non-compliant - nullptr used as an integer
  // compilation error
  F2(0);// Non-compliant - 0 used as the null pointer constant
  F2(NULL); // Non-compliant - NULL used as the null pointer constant
  F2(nullptr); // Compliant
}
void F4(std::int32_t*);
template <class F, class A>
void F5(F f, A a)
{
  F4(a);
}
void F6()
{
  // f5(f4, NULL); // Non-compliant - function f4(std::int32_t) not declared
  F5(F4, nullptr); // Compliant
}