// $Id: A9-5-1.cpp 305588 2018-01-29 11:07:35Z michal.szczepankiewicz $ 2
#include <cstdint>
// Compliant
struct Tagged
{
  enum class TYPE
  {
    UINT,
    FLOAT 
  };
  union {
    uint32_t u;
    float f; 
  };
  TYPE which; 
};

int main(void) 
{
  Tagged un;

  un.u = 12;
  un.which = Tagged::TYPE::UINT;
   
  un.u = 3.14f;
  un.which = Tagged::TYPE::FLOAT;

  return 0; 
}