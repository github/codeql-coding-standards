class A // NON_COMPLIANT
{
public:
  A &operator=(const A &a);
};

class B // NON_COMPLIANT
{
public:
  B &operator=(const B &b);
};

// COMPLIANT
A &operator+=(const A &l, const A &r) {
  A a;
  return a;
}

A &operator+(const A &l, const A &r) {
  A a;
  return a;
}

// NON_COMPLIANT
B &operator+(const B &l, const B &r) {
  B b;
  return b;
}
