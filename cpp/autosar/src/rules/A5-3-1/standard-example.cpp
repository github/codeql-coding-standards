// $Id: A5-3-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <typeinfo>
bool SideEffects() noexcept
{
  // Implementation
  return true;
}
class A
{
  public:
    static A& F1() noexcept { return a; } 
    virtual ~A() {}

  private: 
    static A a;
};
A A::a;
void F2() noexcept(false) 
{
  typeid(SideEffects()); // Non-compliant - sideEffects() function not called 
  typeid(A::F1()); // Non-compliant - A::f1() functions called to determine
                   // the polymorphic type
}