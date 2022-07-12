//% $Id: A25-4-1.cpp 309738 2018-03-01 15:08:00Z michal.szczepankiewicz $
#include <functional> 
#include <iostream> 
#include <set>

int main(void)
{
  //non-compliant, given predicate does not return false
  //for equal values
  std::set<int, std::greater_equal<int>> s{2, 5, 8};
  auto r = s.equal_range(5);
  //returns 0
  std::cout << std::distance(r.first, r.second) << std::endl;

  //compliant, using default std::less<int>
  std::set<int> s2{2, 5, 8};
  auto r2 = s2.equal_range(5);
  //returns 1
  std::cout << std::distance(r2.first, r2.second) << std::endl;

  return 0;
}