// $Id: A12-6-1.cpp 271696 2017-03-23 09:23:09Z piotr.tanski $
#include <cstdint>
#include <string>
class A
{
    public:
      A(std::int32_t n, std::string s) : number{n}, str{s} // Compliant
      {
      }
      // Implementation

    private:
      std::int32_t number; 
      std::string str;
};
class B 
{
  public:
    B(std::int32_t n, std::string s) // Non-compliant - no member initializers 
    { 
      number = n;
      str = s; 
    }
    // Implementation

  private:
    std::int32_t number; 
    std::string str;
};
class C {
  public:
    C(std::int32_t n, std::string s) : number{n}, str{s} // Compliant 
    {
        n += 1; // This does not violate the rule 
        str.erase(str.begin(), 
                  str.begin() + 1); // This does not violate the rule
    }
    // Implementation
  
  private:
    std::int32_t number; 
    std::string str;
};
