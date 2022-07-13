#include <memory>
#include <utility>

std::shared_ptr<int>
shared_ptr_assumes_ownership(std::shared_ptr<int> v1) { // COMPLIANT
  return v1;
}

void shared_ptr_ref_replace_object(std::shared_ptr<int> &v1) { // COMPLIANT
  v1.reset();
}

void shared_ptr_ref_const(const std::shared_ptr<int> &v1) { // NON_COMPLIANT
  return;
}

void shared_ptr_ref_const_copy(const std::shared_ptr<int> &v1) { // COMPLIANT
  std::shared_ptr<int> v2 = v1;
}

void shared_ptr_ref_nil(std::shared_ptr<int> &v1) { // NON_COMPLIANT
  return;
}

void shared_ptr_raw_ptr(std::shared_ptr<int> *v1) { // NON_COMPLIANT
  return;
}

void shared_ptr_rvalue_ref_ownership(
    std::shared_ptr<int> &&v1) { // NON_COMPLIANT
  std::shared_ptr<int> v2(std::move(v1));
}

void shared_ptr_rvalue_ref_nil(std::shared_ptr<int> &&v1) { // NON_COMPLIANT
  return;
}