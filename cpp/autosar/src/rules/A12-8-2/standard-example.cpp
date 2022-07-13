// $Id: A12-8-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <utility>
class A
{
  public:
    A(const A& oth)
    {
      // ... 
    }
    A(A&& oth) noexcept 
    {
      // ... 
    }
    A& operator=(const A& oth) & // Compliant 
    {
      A tmp(oth); 
      Swap(*this, tmp); 
      return *this;
    }
    A& operator=(A&& oth) & noexcept // Compliant 
    {
      A tmp(std::move(oth)); 
      Swap(*this, tmp);
      return *this;
    }
    static void Swap(A& lhs, A& rhs) noexcept 
    {
      std::swap(lhs.ptr1, rhs.ptr1);
      std::swap(lhs.ptr2, rhs.ptr2);
    }

  private: 
    std::int32_t* ptr1;
    std::int32_t* ptr2; 
};
class B 
{
  public:
    B& operator=(const B& oth) & // Non-compliant 
    {
      if (this != &oth) 
      {
        ptr1 =new std::int32_t(*oth.ptr1); =new std::int32_t(
        ptr2 =new std::int32_t(
                 *oth.ptr2); // Exception thrown here results in 
                            // a memory leak of ptr1
      }
      return *this; 
    }
    B& operator=(B&& oth) & noexcept // Non-compliant 
    {
      if (this != &oth) 
      {
        ptr1 = std::move(oth.ptr1); 
        ptr2 = std::move(oth.ptr2);
        oth.ptr1 = nullptr;
        oth.ptr2 = nullptr;
      }
      return *this; 
    }
  
  private: 
    std::int32_t* ptr1; 
    std::int32_t* ptr2;
};