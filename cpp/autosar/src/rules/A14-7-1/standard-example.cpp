// $Id: A14-7-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint> 
class A
{
  public:
    void SetProperty(std::int32_t x) noexcept { property = x; } 
    void DoSomething() noexcept {}

  private:
    std::int32_t property; 
};
struct B
{
};
class C
{
  public:
    void DoSomething() noexcept {} 
};
template <typename T>
class D
{
  public:
    void F1() {}
    void F2()
    {
      T t;
      t.SetProperty(0); 
    }
    void F3()
    {
      T t;
      t.DoSomething();
    }
};

void Fn() noexcept
{
  D<A> d1; // Compliant - struct A provides all needed members
  d1.F1();
  d1.F2();
  d1.F3();

  D<B> d2; // Non-compliant - struct B does not provide needed members d2.F1();
  // d2.f2(); // Compilation error - no ’property’ in struct B
  // d2.f3(); // Compilation error - no member named ’doSomething’ in struct 
  // B

  D<C> d3; // Non-compliant - struct C does not provide property
  d3.F1();
  // d3.F2(); // Compilation error - no property in struct C
  d3.F3();
}