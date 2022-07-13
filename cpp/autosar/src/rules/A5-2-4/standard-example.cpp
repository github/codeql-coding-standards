// $Id: A5-2-4.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint> 
#include <string> 
void F1() noexcept
{
  std::string str = "Hello";
  std::int32_t* ptr = reinterpret_cast<std::int32_t*>(&str); // Non-compliant
}
struct A 
{
  std::int32_t x;
  std::int32_t y; 
};
class B 
{
  public:
    virtual ~B() {}

  private: 
    std::int32_t x;
};
class C : public B
{
};
class D : public B
{
};
void F2(A* ptr) noexcept 
{
  B* b1 = reinterpret_cast<B*>(ptr); // Non-compliant 
  std::int32_t num = 0;
  A* a1 = reinterpret_cast<A*>(num); // Non-compliant 
  A*a2=(A*)num; // Compliant with this rule, but non-compliant with Rule A5-2-2. 
  B* b2 = reinterpret_cast<B*>(num); // Non-compliant
  D d;
  C* c1 = reinterpret_cast<C*>(&d); // Non-compliant - cross cast
  C* c2 = (C*)&d; // Compliant with this rule, but non-compliant with Rule
                  // A5-2-2. Cross-cast.
  B* b3 = &d; // Compliant - class D is a subclass of class B
}