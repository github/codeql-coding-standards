#include <algorithm>
#include <cstdint>
#include <deque>
#include <iostream>
#include <stdexcept>
#include <vector>
class A {
public:
  // Constructor and assignment operator of A class may throw exception
  explicit A(int value) noexcept(false) : x(value) {
    if (x == 0) {
      throw std::runtime_error("error");
    }
  }

  int x;
};

int main(int, char **) {
  constexpr int size = 10;

  std::vector<A> vec1;

  try {
    vec1.push_back(A(0));          // COMPLIANT
    vec1.emplace(vec1.begin(), 0); // NON_COMPLIANT
  } catch (std::runtime_error &e) {
    std::cout << "Error in emplace()" << std::endl;
  }

  std::vector<A> vec2;
  try {
    vec2.push_back(A(0)); // COMPLIANT

  } catch (std::runtime_error &e) {
    std::cout << "Error in push_back()" << std::endl;
  }

  vec2.insert(vec2.begin(), A(0)); // NON_COMPLIANT
  vec2.insert(vec2.end(), A(0));   // COMPLIANT

  std::deque<A> deq;
  deq.insert(deq.begin(), A(0));   // COMPLIANT
  deq.insert(++deq.begin(), A(0)); // NON_COMPLIANT
  deq.insert(deq.end(), A(0));     // COMPLIANT

  for (A a : vec1)
    std::cout << a.x << ' ';
  std::cout << std::endl;

  for (A a : vec2)
    std::cout << a.x << ' ';
  std::cout << std::endl;

  return 0;
}
