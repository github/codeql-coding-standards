// $Id: A12-8-3.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <iostream>
#include <memory>
#include <string>
void F1()
{
  std::string s1{"string"};
  std::string s2{std::move(s1)};
  // ...
  std::cout << s1 << "\n"; // Non-compliant - s1 does not contain "string"
                           // value after move operation
}
void F2()
{
  std::unique_ptr<std::int32_t> ptr1 = std::make_unique<std::int32_t>(0); 
  std::unique_ptr<std::int32_t> ptr2{std::move(ptr1)};
  std::cout << ptr1.get() << std::endl; // Compliant by exception - move
                                        // construction of std::unique_ptr
                                        // leaves moved-from object in a
                                        // well-specified state
}