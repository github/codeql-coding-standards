#include <cstdio> // Non-compliant
void fn()
{
  char_t array [10];
  gets(array); // Can lead to buffer over-run
}