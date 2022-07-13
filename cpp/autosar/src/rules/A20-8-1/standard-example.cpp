// $Id: A20-8-1.cpp 305588 2018-01-29 11:07:35Z michal.szczepankiewicz $
#include <memory>
void Foo()
{
  uint32_t *i = new uint32_t{5}; 
  std::shared_ptr<uint32_t> p1(i); 
  std::shared_ptr<uint32_t> p2(i); // non-compliant
}

void Bar()
{
  std::shared_ptr<uint32_t> p1 = std::make_shared<uint32_t>(5); 
  std::shared_ptr<uint32_t> p2(p1); //compliant
}