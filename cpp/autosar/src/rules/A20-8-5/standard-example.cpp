// $Id: A20-8-5.cpp 308507 2018-02-21 13:23:57Z michal.szczepankiewicz $
#include <memory> 
#include <cstdint> 
#include <functional>
struct A
{
  A() { throw std::runtime_error("example"); } 
  A(std::uint8_t xx, std::uint8_t yy) : x(xx), y(yy) {}
  std::uint8_t x; 
  std::uint8_t y; 
};

void Foo(std::unique_ptr<A> a, std::unique_ptr<A> b) { }
int main(void)
{
  //compliant
  std::unique_ptr<A> upA = std::make_unique<A>(4,6);
  //non-compliant
  std::unique_ptr<A> upA2 = std::unique_ptr<A>(new A(5,7));

  //non-compliant, potential memory leak, as A class constructor throws 
  Foo(std::unique_ptr<A>(new A()), std::unique_ptr<A>(new A())); 
  //non-compliant, potential memory leak, as A class constructor throws 
  Foo(std::make_unique<A>(4,6), std::unique_ptr<A>(new A())); 
  //compliant, no memory leaks
  Foo(std::make_unique<A>(4,6), std::make_unique<A>(4,6));

  //compliant by exception
  std::unique_ptr<A, std::function<void(A*)>> ptr(new A(4,5), [](A* b) { delete b; } );

  return 0; 
}