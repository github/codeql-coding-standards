// $Id: A7-4-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
std::int32_t Fn1(std::int32_t b) noexcept
{
  std::int32_t ret = 0;
  // ...
  asm("pushq %%rax \n"
      "movl %0, %%eax \n" 
      "addl %1, %%eax \n" 
      "movl %%eax, %0 \n" 
      "popq %%rax"
      : "=r"(ret)
      : "r"(b)); // Non-compliant 
  return ret;
}
std::int32_t Fn2(std::int32_t b) noexcept 
{
  std::int32_t ret = 0;
  // ...
  ret += b; // Compliant - equivalent to asm(...) above 
  return ret;
}