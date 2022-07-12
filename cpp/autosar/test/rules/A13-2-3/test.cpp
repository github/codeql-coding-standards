class A {};

bool operator==(A const &, A const &) { return true; }
bool operator<(A const &, A const &) { return true; } // COMPLIANT

A operator!=(A const &lhs, A const &rhs) { return lhs; }
A operator>(A const &lhs, A const &) { return lhs; } // NON_COMPLIANT