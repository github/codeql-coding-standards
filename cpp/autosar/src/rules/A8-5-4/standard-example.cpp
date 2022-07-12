// $Id: A8-5-4.cpp 319328 2018-05-15 10:30:25Z michal.szczepankiewicz $
#include <cstdint> 
#include <initializer_list> 
#include <vector>
#include <iostream>

//non-compliant, there are other constructors 
//apart from initializer_list one defined
class A
{
  public:
    A() = default;
    A(std::size_t num1, std::size_t num2) : x{num1}, y{num2} {} 
    A(std::initializer_list<std::size_t> list) : x{list.size()}, y{list.size()} {
    }
  private:
    std::size_t x;
    std::size_t y; 
};
class B { 
  public:
    B() = default;
    B(std::initializer_list<std::size_t> list) : collection{list} { }
  
  private:
    std::vector<std::size_t> collection;
};

void F1() noexcept {
  A a1{};       // Calls A::A()
  A a2{{}};     // Calls A::A(std::initializer_list<std::size_t>)
  A a3{0, 1};   // Calls A::A(std::initializer_list<std::size_t>), not recommended 
  A a4({0, 1}); // Calls A::A(std::initializer_list<std::size_t>), recommended
  A a5(0, 1);   // Calls A::A(std::size_t, std::size_t), compliant with A8-5-2 by exception
}

void F2() noexcept {
  B b1{};       // Calls B::B()
  B b2{{}};     // Calls B::B(std::initializer_list<std::size_t>)
  B b3{1, 2};   // Calls B::B(std::initializer_list<std::size_t>), not recommended
  B b4({1, 2}); // Calls B::B(std::initializer_list<std::size_t>), recommended
}