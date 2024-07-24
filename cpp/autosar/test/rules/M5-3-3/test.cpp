class A {
  A operator&();                      // NON_COMPLIANT - unary
  constexpr A operator&(const A rhs); // COMPLIANT - binary
};

class B {};

B operator&(B b);                                // NON_COMPLIANT - unary
constexpr B operator&(const B lhs, const B rhs); // COMPLIANT - binary