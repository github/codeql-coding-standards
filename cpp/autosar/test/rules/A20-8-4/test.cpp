#include <memory>

void shared_ptr_obj_param(std::shared_ptr<int> sp) { return; }

void shared_ptr_ref_param(std::shared_ptr<int> &sp) { return; }

void raw_ptr_param(int *val) { return; }

std::shared_ptr<int> g_sp1;

std::shared_ptr<int> f1() {
  std::shared_ptr<int> sp1 = std::make_shared<int>(0); // COMPLIANT
  std::shared_ptr<int> sp2 = std::make_shared<int>(0); // COMPLIANT
  std::shared_ptr<int> sp3 = std::make_shared<int>(0); // NON_COMPLIANT
  std::shared_ptr<int> sp4 = std::make_shared<int>(0); // COMPLIANT
  std::shared_ptr<int> sp5 = std::make_shared<int>(0); // NON_COMPLIANT
  std::shared_ptr<int> sp6;                            // NON_COMPLIANT
  std::shared_ptr<int> sp7;                            // COMPLIANT

  shared_ptr_obj_param(sp1);
  shared_ptr_ref_param(sp2);
  raw_ptr_param(sp3.get());

  sp7 = std::make_shared<int>(0);
  g_sp1 = sp7;

  return sp4;
}