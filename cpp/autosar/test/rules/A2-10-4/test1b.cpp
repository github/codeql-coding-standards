namespace ns1 {
static int v1 = 3; // NON_COMPLIANT
} // namespace ns1

namespace ns3 {
static void f1() {} // NON_COMPLIANT - Not accepted by Clang linker
void f2() {}        // COMPLIANT - Not accepted by Clang linker
} // namespace ns3
