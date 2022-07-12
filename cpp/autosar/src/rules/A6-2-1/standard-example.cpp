// $Id: A6-2-1.cpp 305786 2018-01-30 08:58:33Z michal.szczepankiewicz $
#include <cstdint>
#include <utility>
class A
{
  public:
    A& operator=(const A& oth) // Compliant 
    {
      if(&oth == this) 
      {
        return *this; 
      }
      x = oth.x;
      return *this; 
    }
  
  private: 
    std::int32_t x;
};

class B 
{ 
  public:
    ~B() { delete ptr; }

    //compliant
    B& operator=(B&& oth) 
    {
      if(&oth == this) 
      {
        return *this; 
      }
      ptr = std::move(oth.ptr);
     // Compliant - this is not a side-effect, in this
     // case it is essential to leave moved-from object 
     // in a valid state, otherwise double deletion will 
     // occur.
     return *this;
    }
  
  private:
    std::int32_t* ptr; 
};

class C 
{ 
  public:
    C& operator=(const C& oth) 
    {
      if(&oth == this) 
      {
        return *this; 
      }
      x = oth.x % 2; // Non-compliant - unrelated side-effect
      return *this; 
    }
  
  private: 
    std::int32_t x;
};

class D 
{ 
  public:
    explicit D(std::uint32_t a) : a(a), noOfModifications(0) {}
    D& operator=(const D& oth) 
    {
      if(&oth == this) 
      {
        return *this; 
      }
      a = oth.a;
      //compliant, not copying the debug information about number of modifications
      return *this; 
    }
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