// $Id: A8-4-12.cpp 308795 2018-02-23 09:27:03Z michal.szczepankiewicz $
#include <memory>
#include <iostream>

//compliant, transfers an ownership
void Value(std::unique_ptr<int> v) { }

//compliant, replaces the managed object
void Lv1(std::unique_ptr<int>& v)
{
  v.reset();
}

//non-compliant, does not replace the managed object
void Lv2(std::unique_ptr<int>& v) {}

//compliant by exception
void Rv1(std::unique_ptr<int>&& r)
{
  std::unique_ptr<int> v(std::move(r));
}
 
  //non-compliant
  void Rv2(std::unique_ptr<int>&& r) {}

  int main(void)
  {
    auto sp = std::make_unique<int>(7);
    Value(std::move(sp));
    //sp is empty
 
   auto sp2 = std::make_unique<int>(9);
   Rv1(std::move(sp2));
   //sp2 is empty, because it was moved from in Rv1 function
 
   auto sp3 = std::make_unique<int>(9);
   Rv2(std::move(sp3));
   //sp3 is not empty, because it was not moved from in Rv1 function

   return 0;
}