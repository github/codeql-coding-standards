#include <algorithm>
#include <iostream>
#include <vector>

void f1(std::vector<int> &c, std::vector<int> &d) {

  std::vector<int>::iterator it1 = c.begin();
  std::vector<int>::iterator it2 = c.begin();

  std::vector<int>::iterator it3 = d.begin();

  std::vector<int>::difference_type diff1 = it1 - it2; // COMPLIANT
  std::vector<int>::difference_type diff2 = it2 - it3; // NON_COMPLIANT

  std::vector<int>::const_iterator it1c = c.cbegin();
  std::vector<int>::const_iterator it2c = c.cbegin();
  std::vector<int>::const_iterator it3c = d.cbegin();

  std::vector<int>::difference_type diff3 = it1c - it2c; // COMPLIANT
  std::vector<int>::difference_type diff4 = it2c - it3c; // NON_COMPLIANT
}