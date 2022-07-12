// $Id: A8-4-11.cpp 307966 2018-02-16 16:03:46Z christof.meerwald $
#include <cstdint>
#include <memory>
#include <numeric>
#include <vector>

class A
{
  public:
    void do_stuff();
};

// Non-Compliant: passing object as smart pointer
void foo(std::shared_ptr<A> a) 
{
  if (a) 
  {
    a->do_stuff(); 
  }
  else
  {
    // ... 
  }
}

// Compliant: passing as raw pointer instead
void bar(A *a) {
  if (a != nullptr) {
    a->do_stuff(); 
  }
  else
  {
    // ... 
  }
}

class B 
{
  public:
    void add_a(std::shared_ptr<A> a) 
    {
      m_v.push_back(a); 
    }
  private:
    std::vector<std::shared_ptr<A>> m_v;
};

 // Compliant: storing the shared pointer (affecting lifetime)
void bar(B &b, std::shared_ptr<A> a) 
{
  b.add_a(a); 
}