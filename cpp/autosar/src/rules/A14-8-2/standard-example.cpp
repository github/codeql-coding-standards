// $Id: A14-8-2.cpp 312698 2018-03-21 13:17:36Z michal.szczepankiewicz $
#include <cstdint> 
#include <memory> 
#include <iostream>
template <typename T> 
void F1(T t)
{
  //compliant, (a)
  std::cout << "(a)" << std::endl; 
}

template <>
void F1<>(uint16_t* p)
{
  //non-compliant
  //(x), explicit specialization of
  //(a), not (b), due to declaration
  //order
  std::cout << "(x)" << std::endl;
}

template <typename T>
void F1(T* p)
{
  //compliant, (b), overloads (a)
  std::cout << "(b)" << std::endl;
}

template <>
void F1<>(uint8_t* p)
{
  //non-compliant
  //(c), explicit specialization of (b)
  std::cout << "(c)" << std::endl;
}

void F1(uint8_t* p)
{
  //compliant
  //(d), plain function, overloads with (a), (b) 
  //but not with (c)
  std::cout << "(d)" << std::endl;
}

int main(void)
{
  auto sp8 = std::make_unique<uint8_t>(3); 
  auto sp16 = std::make_unique<uint16_t>(3);

  F1(sp8.get());  //calls (d), which might be
                  //confusing, but (c) is non-compliant
  F1(sp16.get()); //calls (b), which might be
                  //confusing, but (b) is non-compliant
}