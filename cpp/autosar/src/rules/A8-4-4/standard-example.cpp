// $Id: A8-4-4.cpp 289816 2017-10-06 11:19:42Z michal.szczepankiewicz $

#include <tuple>

// Non-compliant, remainder returned as the output parameter
int Divide1(int dividend, int divisor, int &remainder) {
  remainder = dividend % divisor;
  return dividend / divisor;
}

// Compliant, both quotient and remainder returned as a tuple
std::tuple<int, int> Divide2(int dividend, int divisor) {
  return std::make_tuple(dividend / divisor, dividend % divisor);
}

// Compliant since C++17, return tuple using list-initialization
// std::tuple<int, int> Divide3(int dividend, int divisor)
//{
// return { dividend / divisor, dividend % divisor };
//}

int main() {
  int quotient, remainder;
  std::tie(quotient, remainder) = Divide2(26, 5); // store in local variables
  // auto [quotient, remainder] = Divide3(26, 5); // since C++17, by
  // structured bindings
  return 0;
}