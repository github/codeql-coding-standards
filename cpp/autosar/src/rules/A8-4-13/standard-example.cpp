// $Id: A8-4-13.cpp 308795 2018-02-23 09:27:03Z michal.szczepankiewicz $ 2
#include <memory>
#include <iostream>

//compliant, explicit ownership sharing
void Value(std::shared_ptr<int> v) { }

//compliant, replaces the managed object
void Lv1(std::shared_ptr<int>& v)
{
  v.reset();
}

//non-compliant, does not replace the managed object
//shall be passed by int& so that API that does not
//extend lifetime of an object is not polluted
//with smart pointers
void Lv2(std::shared_ptr<int>& v)
{
  ++(*v);
}

//compliant, shared_ptr copied in the called function
void Clv1(const std::shared_ptr<int>& v)
{
  Value(v);
}

//non-compliant, const lvalue reference not copied
//to a shared_ptr object on any code path
//shall be passed by const int&
void Clv2(const std::shared_ptr<int>& v)
{
  std::cout << *v << std::endl;
}

//non-compliant
void Rv1(std::shared_ptr<int>&& r) {}