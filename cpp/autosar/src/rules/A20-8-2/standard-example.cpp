// $Id: A20-8-2.cpp 308981 2018-02-26 08:11:52Z michal.szczepankiewicz $
#include <thread>
#include <memory>
struct A
{
  A(std::uint8_t xx, std::uint8_t yy) : x(xx), y(yy) {} 
  std::uint8_t x;
  std::uint8_t y;
};

//consumes object obj or just uses it 
void Foo(A* obj) { }
void Bar(std::unique_ptr<A> obj) { }

int main(void)
{
  A* a = new A(3,5); //non-compliant with A18-5-2 
  std::unique_ptr<A> spA = std::make_unique<A>(3,5);

  //non-compliant, not clear if function assumes 
  //ownership of the object
  std::thread th1{&Foo, a};
  std::thread th2{&Foo, a};
  //compliant, it is clear that function Bar
  //assumes ownership
  std::thread th3{&Bar, std::move(spA)};

  th1.join();
  th2.join();
  th3.join();
  return 0;
}