// $Id: A12-1-3.cpp 291949 2017-10-19 21:26:22Z michal.szczepankiewicz $
#include <cstdint>
#include <string>
class A
{
  public:
    A() : x(0), y(0.0F), str() // Non-compliant
    {
    }
    // ...

  private: 
    std::int32_t x; 
    float y; 
    std::string str;
};
class B {
  public: 
    // ...
  
  private:
    std::int32_t x = 0;   // Compliant
    float y = 0.0F;       // Compliant
    std::string str = ""; // Compliant
};