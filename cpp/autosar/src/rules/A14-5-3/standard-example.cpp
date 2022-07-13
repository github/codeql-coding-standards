// $Id: A14-5-3.cpp $
#include <cstdint>
template<typename T>
class B
{
  public:
  bool operator+(long rhs);
  void f()
  {
    *this + 10; }
  };

namespace NS1
{
  class A {};

  template<typename T>
  bool operator+( T, std::int32_t ); // Non-Compliant: a member of namespace
                                     // with other declarations 
}

namespace NS2
{
  void g();

  template<typename T>
  bool operator+( T, std::int32_t ); // Compliant: a member of namespace
                                     // with declarations of functions only 
}

template class B<NS1::A>; // NS1::operator+ will be used in function B::f()
                          // instead of B::operator+