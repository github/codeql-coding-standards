#include <algorithm>
#include <iostream>
#include <map>
#include <set>
#include <vector>

void m1(std::vector<int> &v, std::map<int, int> &m, std::multimap<int, int> &mm,
        std::set<int> &s, std::multiset<int> &ms) {
  std::vector<int>::const_iterator i1{v.cbegin()}; // COMPLIANT
  std::vector<int>::const_iterator i2{v.begin()};  // NON_COMPLIANT

  std::set<int>::const_iterator i3{s.cbegin()}; // COMPLIANT
  std::set<int>::const_iterator i4{s.begin()};  // NON_COMPLIANT

  std::multiset<int>::const_iterator i5{ms.cbegin()}; // COMPLIANT
  std::multiset<int>::const_iterator i6{ms.begin()};  // NON_COMPLIANT

  std::map<int, int>::const_iterator i7{m.cbegin()}; // COMPLIANT
  std::map<int, int>::const_iterator i8{m.begin()};  // NON_COMPLIANT

  std::multimap<int, int>::const_iterator i9{mm.cbegin()}; // COMPLIANT
  std::multimap<int, int>::const_iterator i10{mm.begin()}; // NON_COMPLIANT

  i1 = v.cbegin();
  i2 = v.begin(); // NON_COMPLIANT
  i3 = s.cbegin();
  i4 = s.begin(); // NON_COMPLIANT
  i5 = ms.cbegin();
  i6 = ms.begin(); // NON_COMPLIANT
  i7 = m.cbegin();
  i8 = m.begin(); // NON_COMPLIANT
  i9 = mm.cbegin();
  i10 = mm.begin(); // NON_COMPLIANT
}
