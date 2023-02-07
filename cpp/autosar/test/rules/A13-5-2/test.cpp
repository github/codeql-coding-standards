class A {
public:
  explicit A(float d) : d(d) {}
  explicit operator float() const { return d; } // COMPLIANT

  operator double() const { return d; } // NON_COMPLIANT
  operator char() const { return d; }   // NON_COMPLIANT
  operator int() const { return d; }    // NON_COMPLIANT
private:
  float d;
};

void example() {

  int ref_value{0};
  int other_value{0};

  // ok
  auto dummy_lambda = [&ref_value]() noexcept -> void { ref_value = 42; };
  dummy_lambda();

  // ok
  auto my_lambda_1 = [&ref_value](int param) noexcept -> void {
    for (int i{0}; i < param; ++i) {
      ++ref_value;
    }
  };
  my_lambda_1(other_value);

  // error: user-defined-conversion-operators-not-defined-explicit
  auto my_lambda_2 = [](int param) noexcept -> void {
    for (int i{0}; i < param; ++i) {
      //
    }
  };
  my_lambda_2(other_value);

  // ok
  auto my_lambda_3 = [&ref_value](int param) noexcept -> void {
    ref_value = param;
  };
  my_lambda_3(other_value);
}
