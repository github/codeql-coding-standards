// $Id: A8-4-7.cpp 305588 2018-01-29 11:07:35Z michal.szczepankiewicz $
#include <cstdint>
#include <iostream>
#include <string>

// Compliant, pass by value
void output(std::uint32_t i)
{
  std::cout << i << '\n'; 
}

// Non-Compliant, std::string is not trivially copyable
void output(std::string s) 
{
  std::cout << s << '\n'; 
}

struct A 
{
  std::uint32_t v1;
  std::uint32_t v2; 
};

// Non-Compliant, A is trivially copyable and no longer than two words
void output(const A &a) 
{
  std::cout << a.v1 << ", " << a.v2 << '\n'; 
}