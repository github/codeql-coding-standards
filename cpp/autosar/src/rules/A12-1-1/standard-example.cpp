// $Id: A12-1-1.cpp 271696 2017-03-23 09:23:09Z piotr.tanski $
#include <cstdint>
class Base
{
  // Implementation
};
class VirtualBase
{
};
class A : public virtual VirtualBase, public Base 
{
  public:
    A() : VirtualBase{}, Base{}, i{0}, j{0} // Compliant 
    {
    }
    A(A const& oth)
             : Base{}, j{0} // Non-compliant - VirtualBase base class and member
                            // i not initialized
    {
    }
  
  private:
    std::int32_t i; 
    std::int32_t j;
    static std::int32_t k;
};
std::int32_t A::k{0};