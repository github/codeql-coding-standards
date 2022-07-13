#include <memory>

void smart_ptr_release(std::unique_ptr<int> up1) { // COMPLIANT
  up1.release();
}

void smart_ptr_get(std::unique_ptr<int> up1) { // NON_COMPLIANT
  up1.get();
  *up1;
}

void smart_ptr_copy(std::shared_ptr<int> sp1) { // COMPLIANT
  std::shared_ptr<int> sp2 = sp1;
}

void smart_ptr_ref_assign_ref(std::shared_ptr<int> &sp1) { // NON_COMPLIANT
  std::shared_ptr<int> &sp2 = sp1;
}

void smart_ptr_ref_copy(std::shared_ptr<int> &sp1) { // COMPLIANT
  std::shared_ptr<int> sp2 = sp1;
}

void smart_ptr_ref_compliant(std::shared_ptr<int> &sp1) { // COMPLIANT
  smart_ptr_ref_copy(sp1);
}

void smart_ptr_ref_noncompliant(std::shared_ptr<int> &sp1) { // NON_COMPLIANT
  smart_ptr_ref_assign_ref(sp1);
}

#include <utility>
#include <vector>
class A8_4_11 {
public:
  void Set(std::unique_ptr<int> &&p) { up_ = std::move(p); }

private:
  std::unique_ptr<int> up_;
};