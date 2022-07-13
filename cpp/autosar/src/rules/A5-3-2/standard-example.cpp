// $Id: A5-3-2.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <iostream>
#include <memory>
#include <cstdint>

class A
{
  public:
    A(std::uint32_t a) : a(a) {}
    std::uint32_t GetA() const noexcept { return a; }

  private: 
    std::uint32_t a;
};

bool Sum(const A* lhs, const A* rhs) 
{
  //non-compliant, not checking if pointer is invalid
  return lhs->GetA() + rhs->GetA(); 
}

int main(void) 
{
  auto l = std::make_shared<A>(3); 
  decltype(l) r;
  
  auto sum = Sum(l.get(), r.get());
  
  std::cout << sum << std::endl;
  return 0; }
}