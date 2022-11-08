#include <utility>
#include <vector>
class TestClass1 {

public:
  explicit TestClass1(std::vector<int> &&v);
};
class TestClass2 {
public:
  explicit TestClass2(const std::vector<int> &v);
};
// template type
template <typename T, typename... X> T make(X &&...x) { // forward param
  return T{std::forward<X>(x)...};                      // COMPLIANT
}
// template type
template <typename T, typename U> T make2(U &&x) { // forward param
  return T{std::move(x)};                          // NON_COMPLIANT
}

// generic lambda
auto test_lambda = [](auto &&x) {      // forward param
  return std::forward<decltype(x)>(x); // COMPLIANT
};

auto test_lambda_2 = [](auto &&x) { // forward param
  return std::move(x);              // NON_COMPLIANT
};

void test_instantiate() {
  std::vector<int> v;

  make<TestClass1>(std::vector<int>{});
  make<TestClass2>(v);

  make2<TestClass1>(std::vector<int>{});
  make2<TestClass2>(v);

  test_lambda(std::vector<int>{});
  test_lambda(v);

  test_lambda_2(std::vector<int>{});
  test_lambda_2(v);
}
