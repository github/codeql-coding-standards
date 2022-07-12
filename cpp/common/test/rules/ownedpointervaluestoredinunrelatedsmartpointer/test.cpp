#include <memory>

void f2(int *v1) {
  int *v2 = v1;
  std::shared_ptr<int> p1(v1);        // NON_COMPLIANT
  new std::shared_ptr<int>(p1.get()); // NON_COMPLIANT
  new std::shared_ptr<int>(v2);       // NON_COMPLIANT
  v2 = nullptr;
  new std::shared_ptr<int>(v2); // COMPLIANT
  v2 = new int(0);
  new std::shared_ptr<int>(v2); // NON_COMPLIANT
  new std::shared_ptr<int>(v2); // NON_COMPLIANT
}

void f1() {
  int *v1 = new int(0);
  std::shared_ptr<int> p1(v1); // NON_COMPLIANT
  std::shared_ptr<int> p3(p1); // COMPLIANT
  f2(v1);
}