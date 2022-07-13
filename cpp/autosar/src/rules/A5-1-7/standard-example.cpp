// $Id: A5-1-7.cpp 289815 2017-10-06 11:19:11Z michal.szczepankiewicz $
#include <cstdint> 
#include <functional> 
#include <vector> 
void Fn()
{
  auto lambda1 = []() -> std::int8_t { return 1; };
  auto lambda2 = []() -> std::int8_t { return 1; };
 
  if (typeid(lambda1) == typeid(lambda2)) // Non-compliant - types of lambda1
                                          // and lambda2 are different
  {
    // ...
  }

  std::vector<decltype(lambda1)> v; // Non-compliant
  // v.push_back([]() { return 1; }); // Compilation error, type of pushed
  // lambda is different than decltype(lambda1)
  // using mylambda_t = decltype([](){ return 1; }); // Non-compliant -
  // compilation error
  auto lambda3 = []() { return 2; };
  using lambda3_t = decltype(lambda3); // Non-compliant - lambda3_t type can
                                       // not be used for lambda expression
                                       // declarations
  // lambda3_t lambda4 = []() { return 2; }; // Conversion error at
  // compile-time
  std::function<std::int32_t()> f1 = []() { return 3; };
  std::function<std::int32_t()> f2 = []() { return 3; };
  
  if (typeid(f1) == typeid(f2)) // Compliant - types are equal
  {
    // ...
  }
}
  
template <typename T>
void Foo(T t);
  
void Bar()
{
  Foo([]() {}); // Compliant
}