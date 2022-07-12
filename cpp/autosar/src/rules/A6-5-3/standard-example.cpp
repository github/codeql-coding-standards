// $Id: A6-5-3.cpp 291350 2017-10-17 14:31:34Z jan.babst $
#include <cstdint>
// Compliant by exception
#define SWAP(a, b)         \ 
  do                       \ 
  {                        \
    decltype(a) tmp = (a); \
    (a) = (b);             \
    (b) = tmp;             \
  } while (0)

// Non-compliant
#define SWAP2(a, b)      \
  decltype(a) tmp = (a); \ 
  (a) = (b);             \
  (b) = tmp;

int main(void) 
{
  uint8_t a = 24; 
  uint8_t b = 12;
  if (a > 12) 
    SWAP(a, b);

  // if (a > 12)
  //SWAP2(a, b);
  // Does not compile, because only the first line is used in the body of the
  // if-statement. In other cases this may even cause a run-time error.
  // The expansion contain two semicolons in a row, which may be flagged by 
  // compiler warnings.
  // Expands to:
   // if (a > 12)
   //decltype(a) tmp = (a);
   // (a) = (b);
   // (b) = tmp;;

   return 0;
}