
#include <algorithm>
#include <iostream>
#include <vector>

void f1(std::vector<int> &c, std::vector<int> &d) {
  std::for_each(c.end(), c.begin(), [](int i) {});   // NON_COMPLIANT
  std::for_each(c.begin(), c.begin(), [](int i) {}); // NON_COMPLIANT
  std::for_each(c.end(), c.end(), [](int i) {});     // NON_COMPLIANT
  std::for_each(c.begin(), c.end(), [](int i) {});   // COMPLIANT

  std::for_each(c.end(), d.begin(), [](int i) {});   // NON_COMPLIANT
  std::for_each(c.begin(), d.begin(), [](int i) {}); // NON_COMPLIANT
  std::for_each(c.begin(), d.end(), [](int i) {});   // NON_COMPLIANT
}

void f2(std::vector<int> &c, std::vector<int> &d) {
  auto i1 = std::remove(c.end(), c.begin(), 1);   // NON_COMPLIANT
  auto i2 = std::remove(c.begin(), c.begin(), 1); // NON_COMPLIANT
  auto i3 = std::remove(c.begin(), c.end(), 1);   // COMPLIANT

  auto i4 = std::remove(c.end(), d.begin(), 1);   // NON_COMPLIANT
  auto i5 = std::remove(d.begin(), c.begin(), 1); // NON_COMPLIANT
  auto i6 = std::remove(c.begin(), d.end(), 1);   // NON_COMPLIANT
}
