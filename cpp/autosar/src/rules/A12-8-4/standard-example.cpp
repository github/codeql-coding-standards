// $Id: A12-8-4.cpp 271696 2017-03-23 09:23:09Z piotr.tanski $
#include <cstdint> 
#include <string> 
class A
{
  public: 
    // ...
    A(A&& oth)
             : x(std::move(oth.x)), // Compliant 
               s(std::move(oth.s))  // Compliant
    { 
    }

  private: 
    std::int32_t x; 
    std::string s;
};
class B 
{
  public: 
    // ...
    B(B&& oth)
             : x(oth.x), // Compliant by exception, std::int32_t is of scalar 
                         // type
               s(oth.s)  // Non-compliant
    { 
    }

  private: 
    std::int32_t x; 
    std::string s;
};
class C 
{
  public: 
    // ...
    C(C&& oth)
             : x(oth.x),           // Compliant by exception
               s(std::move(oth.s)) // Compliant
    {
    }

  private:
    std::int32_t x = 0;
    std::string s = "Default string";
};