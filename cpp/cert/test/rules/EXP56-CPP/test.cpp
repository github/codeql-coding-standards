extern "C" typedef void (*c_callback)(int);
extern void f1(c_callback p1);
void f2(int);
void f() { f1(f2); } // NON_COMPLIANT

extern "C" void f5(int);
void f6() {
  f1(f5); // COMPLIANT
}
