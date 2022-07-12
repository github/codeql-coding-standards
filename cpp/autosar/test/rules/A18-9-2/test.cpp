#include <cstdint>
#include <string>
#include <utility>
class A {
public:
  explicit A(std::string &&param) // rvalue reference
      : str(std::move(param))     // COMPLIANT
  {}

private:
  std::string str;
};
class B {};
void Fn1(const B &lval) {}
void Fn1(B &&rval) {}
template <typename T> void Fn2(T &&param) { // forwarding reference
  Fn1(std::forward<T>(param));              // COMPLIANT
}
template <typename T> void Fn3(T &&param) { // forwarding reference
  Fn1(std::move(param));                    // NON_COMPLIANT
}
void Fn3(std::string &&param) {     // rvalue reference
  std::forward<std::string>(param); // NON_COMPLIANT
}

// generic lambda
auto test_lambda = [](auto &&param) { // forward param
  return std::move(param);            // NON_COMPLIANT
};

void test_instantiate() noexcept {
  B b1;
  B &b2 = b1;

  Fn2(b2); // fn1(const B&) is called
  Fn3(b2); // fn1(const B&) is called

  test_lambda(b2);
}
