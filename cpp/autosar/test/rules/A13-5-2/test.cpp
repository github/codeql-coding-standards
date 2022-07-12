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