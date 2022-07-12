// $Id: A20-8-4.cpp 308507 2018-02-21 13:23:57Z michal.szczepankiewicz $
#include <memory> 
#include <cstdint> 
#include <thread>
struct A
{
  A(std::uint8_t xx, std::uint8_t yy) : x(xx), y(yy) {}
  std::uint8_t x; std::uint8_t y; 
};

void Func()
{
  auto spA = std::make_shared<A>(3,5); 
  //non-compliant, shared_ptr used only locally 
  //without copying it
}

void Foo(std::unique_ptr<A> obj) { }
void Bar(std::shared_ptr<A> obj) { }

int main(void)
{
  std::shared_ptr<A> spA = std::make_shared<A>(3,5); 
  std::unique_ptr<A> upA = std::make_unique<A>(4,6);
  
  //compliant, object accesses in parallel
  std::thread th1{&Bar, spA}; 
  std::thread th2{&Bar, spA}; 
  std::thread th3{&Bar, spA};

  //compliant, object accesses only by 1 thread
  std::thread th4{&Foo, std::move(upA)};

  th1.join(); 
  th2.join(); 
  th3.join(); 
  th4.join();

  return 0; 
}