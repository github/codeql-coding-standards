#include <cstring>
void fn(const char_t * pChar)
{
  char_t array[10];
  strcpy(array, pChar); // Non-compliant
}