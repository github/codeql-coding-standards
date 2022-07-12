//% $Id: A2-10-6.cpp 313821 2018-03-27 11:16:14Z michal.szczepankiewicz $
#include <cstdint>

namespace NS1 {
  class G {};
  void G() {} //non-compliant, hides class G
}

namespace NS2 {
  enum class H { VALUE=0, };
  std::uint8_t H = 17; //non-compliant, hides
                       //scoped enum H
}

namespace NS3 {
  class J {};
  enum H //does not hide NS2::H, but non-compliant to A7-2-3
  {
    J=0, //non-compliant, hides class J
  };
}

int main(void)
{
  NS1::G();
  //NS1::G a; //compilation error, NS1::G is a function
              //after a name lookup procedure
  class NS1::G a{}; //accessing hidden class type name

  enum NS2::H b ; //accessing scoped enum NS2::H
  NS2::H = 7;
 
  class NS3::J c{}; //accessing hidden class type name
  std::uint8_t z = NS3::J;
}