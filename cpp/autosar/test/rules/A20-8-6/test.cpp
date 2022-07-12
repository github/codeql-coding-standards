#include <memory>

void f1() {
  int *v1 = new int(0);
  auto v2 = std::shared_ptr<int>(v1); // NON_COMPLIANT
  auto v3 = std::make_shared<int>(2); // COMPLIANT
  auto v4 = v3;                       // COMPLIANT
}