#include <utility>
#include <vector>

// correct use of move
class TestClass0 {
public:
  int test_val;
  explicit TestClass0(int &&c) // consume parameter
      : test_val{std::move(c)} // COMPLIANT
  {}
};

// correct use of move
class TestClass1 {
public:
  std::vector<int> test_vector;
  explicit TestClass1(std::vector<int> &&c) // consume parameter
      : test_vector{std::move(c)}           // COMPLIANT
  {}
};

// incorrect use of move
class TestClass2 {
public:
  std::vector<int> test_vector;
  explicit TestClass2(std::vector<int> &&c) // consume parameter
      : test_vector{c}                      // NON_COMPLIANT
  {}
};

// the parameter is of template type
template <class T> class TestClass3 {
public:
  T test_val;
  explicit TestClass3(T &&f) // forward parameter
      : test_val{f}          // COMPLIANT
  {}
};

// the parameter is of const type
class TestClass4 {
public:
  std::vector<int> test_vector;
  explicit TestClass4(const std::vector<int> &&p)
      : test_vector{p} // COMPLIANT
  {}
};

// template type
template <typename T, typename... X>
T test_forward(X &&...f) {         // forward parameter
  return T{std::forward<X>(f)...}; // COMPLIANT
}

// generic lambda
auto test_lambda = [](auto &&f) {      // forward parameter
  return std::forward<decltype(f)>(f); // COMPLIANT
};

// operations on the parameter before move
class TestClass5 {
public:
  std::vector<int> test_vector;
  explicit TestClass5(std::vector<int> &&c) { // consume parameter
    c.clear();
    test_vector = std::move(c); // COMPLIANT
  }
};

// operations on the parameter before move
class TestClass6 {
public:
  std::vector<int> test_vector;
  explicit TestClass6(std::vector<int> &&c) { // consume parameter
    c.clear();
    test_vector = c; // NON_COMPLIANT
  }
};

void instantiate() {
  TestClass3<std::vector<int>> tc3_1(std::vector<int>{});
  TestClass3<int> tc3_2(0);
  test_lambda(std::vector<int>{});
  test_lambda(0);
}
