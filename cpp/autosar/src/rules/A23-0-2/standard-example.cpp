// $Id: A23-0-2.cpp 309868 2018-03-02 10:47:23Z jan.babst $
#include <algorithm> 
#include <cstdint> 
#include <list> 
#include <vector>

void f()
{
  std::vector<int32_t> v{0, 1, 2, 3, 4, 5, 6, 7};
  auto it = std::find(v.begin(), v.end(), 5); // *it is 5

  // These calls may lead to a reallocation of the vector storage 
  // and thus may invalidate the iterator it.
  v.push_back(8);
  v.push_back(9);

  *it = 42; // Non-compliant
}

void g()
{
  std::list<int32_t> l{0, 1, 2, 3, 4, 5, 6, 7};

  auto it = std::find(l.begin(), l.end(), 5); // *it is 5
  l.remove(7);
  l.push_back(9);
  *it = 42; // Compliant - previous operations do not invalidate iterators 
  // l is now {0, 1, 2, 3, 4, 42, 6, 9 }
}