class A {
public:
  A &operator+=(A const &oth);
  friend A const operator+(A const &lhs, A const &rhs); // NON_COMPLIANT
};

class B {
public:
  B &operator+=(B const &oth);
  friend bool operator==(B const &lhs, B const &rhs) // COMPLIANT - by exception
  {
    return true;
  }
};

B const operator+(B const &lhs, B const &rhs) // COMPLIANT
{
  return lhs;
  // Implementation
}
