#include <memory>
#include <vector>

template <class T> class auto_ptr {
public:
  auto_ptr() throw(); // COMPLIANT
};

std::auto_ptr<bool> g; // NON_COMPLIANT
auto_ptr<long> g1;     // COMPLIANT

template <typename T> T f2(T d2) { return d2; }

void f() {
  std::auto_ptr<bool> l;                           // NON_COMPLIANT
  std::vector<long> l2;                            // COMPLIANT
  std::vector<std::auto_ptr<bool>> l3;             // NON_COMPLIANT
  std::vector<std::vector<std::auto_ptr<int>>> l4; // NON_COMPLIANT
  std::vector<std::vector<std::vector<int>>> l5;   // COMPLIANT

  l = f2(l);   // COMPLIANT
  l2 = f2(l2); // COMPLIANT
}

std::auto_ptr<bool> f3(std::auto_ptr<bool> d3) { return d3; } // NON_COMPLIANT