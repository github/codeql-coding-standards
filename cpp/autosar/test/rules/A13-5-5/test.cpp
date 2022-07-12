/*Comparison operators shall be non-member functions
 with identical parameter types and noexcept.*/
class A {
  // NON_COMPLIANT: member, not noexcept
};
bool operator==(A const &rhs, int lhs) { return true; }

class B {};
bool operator==(B const &lhs, B const &rhs) noexcept {
  return true;
} // COMPLIANT: non-member, identical
  // parameter types, noexcept