
class A {};
bool operator&&(A const &, A const &) {
  return true;
} // NON_COMPLIANT overloaded
bool operator||(A const &, A const &) {
  return true;
} // NON_COMPLIANT overloaded
bool operator,(A const &, A const &) {
  return true;
} // NON_COMPLIANT overloaded
