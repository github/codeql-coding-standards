int f();
void g(int x);

class A {
public:
  A operator+(const A &other);
};

void test_return_val() {
  f();                    // NON_COMPLIANT - return value never read
  static_cast<void>(f()); // COMPLIANT
  int x = f(); // COMPLIANT - according to the rule, even though it's not in
               // practice used because the unused assignment would be flagged
               // by A0-1-1
  g(f());      // COMPLIANT - g is a void function, f() is used by g();
  A a1;
  A a2;
  a1 + a2; // COMPLIANT - `+` is a call to operator+, but is permitted by the
           // rule
}