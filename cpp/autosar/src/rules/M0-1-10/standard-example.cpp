void f1() {}
void f2() {} // Non-compliant
void f3();   // Compliant prototype
int32_t main() {
  f1();
  return (0);
}