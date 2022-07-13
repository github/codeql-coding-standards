#include <memory>
#include <utility>

std::unique_ptr<int>
unique_ptr_assumes_ownership(std::unique_ptr<int> v1) { // COMPLIANT
  return v1;
}

void unique_ptr_ref_replace_object(std::unique_ptr<int> &v1) { // COMPLIANT
  v1.reset();
}

void unique_ptr_ref_const(const std::unique_ptr<int> &v1) { // NON_COMPLIANT
  return;
}

void unique_ptr_ref_nil(std::unique_ptr<int> &v1) { // NON_COMPLIANT
  return;
}

void unique_ptr_ref_assumes_ownership(
    std::unique_ptr<int> &v1) { // NON_COMPLIANT
  std::unique_ptr<int> v2 = std::move(v1);
}

void unique_ptr_raw_ptr(std::unique_ptr<int> *v1) { // NON_COMPLIANT
  return;
}

void unique_ptr_rvalue_ref_ownership(std::unique_ptr<int> &&v1) { // COMPLIANT
  std::unique_ptr<int> v2(std::move(v1));
}

void unique_ptr_rvalue_ref_nil(std::unique_ptr<int> &&v1) { // NON_COMPLIANT
  return;
}