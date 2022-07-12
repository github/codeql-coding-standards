#include <functional>

auto test_return_dangling_reference_to_local() {
  int l1 = 0;
  auto l2 = [&]() { l1++; };
  return l2; // NON_COMPLIANT
}

auto test_return_copy_of_local() {
  int l1 = 0;
  return [=]() { return l1 + 1; }; // COMPLIANT
}

class C1 {
public:
  auto test_return_dangling_reference_to_this() {
    return [&]() { return m1 + 1; }; // NON_COMPLIANT
  }

private:
  int m1;
};

auto test_return_dangling_reference_to_local_captured_by_outer_lambda() {
  auto outer = [](auto val) {
    auto inner = [&]() { return val + 1; };
    return inner; // NON_COMPLIANT
  };
  return outer(1);
}

auto test_return_reference_to_parameter(int i) {
  return [&]() { return i + 1; }; // NON_COMPLIANT
}

auto test_return_reference_to_pointer_parameter(int *i) {
  return [&]() { return i + 1; }; // NON_COMPLIANT
}

auto test_return_reference_to_reference_parameter(int &i) {
  return [&]() { return i + 1; }; // COMPLIANT
}

std::function<int()> test_ctor_result_returned_with_reference_parameter() {
  int data;
  return ([&data]() -> int { return data; }); // NON_COMPLIANT
}

std::function<int(int *)> test_ctor_result_returned_with_parameter() {
  int data;
  return ([data](int *pdata) -> int {
    pdata = const_cast<int *>(&data);
    return data;
  }); // COMPLIANT
}

static int *psdata;
std::function<int()> test_ctor_result_returned_with_parameter_b() {
  int data;
  return ([data]() -> int {
    psdata = const_cast<int *>(&data);
    return data;
  }); // COMPLIANT
}