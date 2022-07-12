#ifndef MY_HDR
#define MY_HDR // Compliant
namespace NS
{
  #define FOO  // Non-compliant
  #undef FOO   // Non-compliant
} 
#endif