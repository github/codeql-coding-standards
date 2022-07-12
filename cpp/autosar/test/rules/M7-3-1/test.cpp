int g1;    // NON_COMPLIANT
void f1(); // NON_COMPLIANT

int main() { return 0; } // COMPLIANT
extern "C" void f2();    // COMPLIANT

namespace ns1 { // COMPLIANT
int m1;
void f1();
} // namespace ns1
