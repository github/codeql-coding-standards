// $Id: A20-8-3.cpp 308507 2018-02-21 13:23:57Z michal.szczepankiewicz $
#include <memory> 
#include <cstdint> 
#include <thread>
struct A
{
  A(std::uint8_t xx, std::uint8_t yy) : x(xx), y(yy) {}
  std::uint8_t x; 
  std::uint8_t y; 
};

void Foo(A* obj) { }
void Bar(A* obj) { }

void Foo2(std::shared_ptr<A> obj) { }
void Bar2(std::shared_ptr<A> obj) { }

int main(void)
{
  A* a = new A(3,5); //non-compliant with A18-5-2 
  std::shared_ptr<A> spA = std::make_shared<A>(3,5); 

  //non-compliant, not clear who is responsible
  //for deleting object a
  std::thread th1{&Foo, a};
  std::thread th2{&Bar, a};

  //compliant, object spA gets deleted
  //when last shared_ptr gets destructed
  std::thread th3{&Foo2, spA};
  std::thread th4{&Bar2, spA};

  th1.join();
  th2.join();
  th3.join();
  th4.join();

  return 0;
}