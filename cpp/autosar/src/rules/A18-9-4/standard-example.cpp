// $Id: A18-9-4.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <iostream>
#include <utility>
template <typename T1, typename T2> 
void F1(T1 const& t1, T2& t2){
  // ...
};
template <typename T1, typename T2>
void F2(T1&& t1, T2&& t2)
{
  f1(std::forward<T1>(t1), std::forward<T2>(t2)); 
  ++t2; // Non-compliant
};