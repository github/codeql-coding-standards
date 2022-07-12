// $Id: A12-8-1.cpp 303582 2018-01-11 13:42:56Z michal.szczepankiewicz $
#include <cstdint>
#include <utility>
class A
{
  public:
    // Implementation
    A(A const& oth) : x(oth.x) // Compliant
    {
    }
  
  private: 
    std::int32_t x;
};
class B 
{
  public:
    // Implementation
    B(B&& oth) : ptr(std::move(oth.ptr)) // Compliant 
    {
      oth.ptr = nullptr; // Compliant - this is not a side-effect, in this
                         // case it is essential to leave moved-from object 
                         // in a valid state, otherwise double deletion will
                         // occur.
    }
    ~B() { delete ptr; }
  
  private: 
    std::int32_t* ptr;
};
class C 
{
  public:
    // Implementation
    C(C const& oth) : x(oth.x) 
    {
      // ...
      x = x % 2; // Non-compliant - unrelated side-effect 
    }
  private: 
    std::int32_t x;
};

class D 
{ 
  public:
    explicit D(std::uint32_t a) : a(a), noOfModifications(0) {}
    D(const D& d) : D(d.a) {} //compliant, not copying the debug information about number of modifications
    void SetA(std::uint32_t aa) 
    {
      ++noOfModifications;
      a = aa; 
    }
    std::uint32_t GetA() const noexcept 
    {
      return a; 
    }

  private: 
    std::uint32_t a;
    std::uint64_t noOfModifications; 
};