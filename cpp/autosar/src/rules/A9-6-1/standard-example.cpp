// $Id: A9-6-1.cpp 319312 2018-05-15 08:29:17Z christof.meerwald $
#include <cstdint>

enum class E1 : std::uint8_t
{
  E11, 
  E12, 
  E13
};
enum class E2 : std::int16_t 
{
  E21, 
  E22, 
  E23
};
enum class E3 
{
  E31, 
  E32, 
  E33
};
enum E4 
{
  E41, 
  E42, 
  E43
};

class C 
{
  public:
    std::int32_t a : 2;  //Compliant
    std::uint8_t b : 2U; //Compliant

    bool c : 1; // Non-compliant - the size of bool is implementation defined 
    
    char d : 2; // Non-compliant
    wchar_t e : 2; // Non-compliant - the size of wchar_t is implementation defined

    E1 f1 : 2; // Compliant 
    E2 f2 : 2; // Compliant
    E3 f3 : 2; // Non-compliant - E3 enum class does not explicitly define 
               // underlying type
    E4 f4 : 2; // Non-compliant - E4 enum does not explicitly define underlying 
               // type
};

struct D {
  std::int8_t a; // Compliant
  bool b;        // Non-compliant - the size of bool is 
                // implementation defined
  std::uint16_t c1 :8; // Compliant
  std::uint16_t c2 :8; // Compliant
};

void Fn() noexcept 
{
  C c;
  c.f1 = E1::E11; 
}