//% $Id: A3-3-1.hpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
extern std::int32_t a1;
extern void F4();
namespace n {
void F2();
std::int32_t a5; // Compliant, external linkage
} // namespace n
//% $Id: A3-3-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include "A3-3-1.hpp"
std::int32_t a1 = 0;        // Compliant, external linkage
std::int32_t a2 = 0;        // Non-compliant, static keyword not used
static std::int32_t a3 = 0; // Compliant, internal linkage
namespace {
std::int32_t a4 = 0; // Compliant by exception
void F1()            // Compliant by exception
{}
} // namespace
namespace n {
void F2() // Compliant, external linkage
{}
std::int32_t a6 = 0; // Non-compliant, external linkage
} // namespace n
extern std::int32_t a7; // Non-compliant, extern object declared in .cpp file
static void F3()        // Compliant, static keyword used
{}
void F4() // Compliant, external linkage
{
  a1 = 1;
  a2 = 1;
  a3 = 1;
  a4 = 1;
  n::a5 = 1;
  n::a6 = 1;
  a7 = 1;
}
void F5() // Non-compliant, static keyword not used
{
  a1 = 2;
  a2 = 2;
  a3 = 2;
  a4 = 2;
  n::a5 = 2;
  n::a6 = 2;
  a7 = 2;
}
int main(int, char **) // Compliant by exception
{
  F1();
  n::F2();
  F3();
  F4();
  F5();
}