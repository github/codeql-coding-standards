// $Id: A12-1-2.cpp 271696 2017-03-23 09:23:09Z piotr.tanski $
#include <cstdint>
#include <utility>
class A
{
  public:
    A() : i1{0}, i2{0} // Compliant - i1 and i2 are initialized by the
                       // constructor only. Not compliant with A12-1-3
    {
    }
    // Implementation

  private: 
    std::int32_t i1; 
    std::int32_t i2;
};
class B 
{
  public:
    // Implementation
  
  private:
    std::int32_t i1{0}; 
    std::int32_t i2{0}; // Compliant - both i1 and i2 are initialized by NSDMI only
};
class C 
{
  public:
    C() : i2{0} // Non-compliant - i1 is initialized by NSDMI, i2 is in
                // member in member initializer list
    {
    }
    C(C const& oth) : i1{oth.i1}, i2{oth.i2} // Compliant by exception 
    {
    }
    C(C&& oth)
            : i1{std::move(oth.i1)},
              i2{std::move(oth.i2)} // Compliant by exception
    {
    }
    // Implementation
  private:
    std::int32_t i1{0}; 
    std::int32_t i2;
};