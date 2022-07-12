namespace ns1 {
class C1 {};
void C1() {} // NON_COMPLIANT

enum E1 { E1_1 };
int E1; // NON_COMPLIANT

class C2 {};
enum E2 {
  C2 // NON_COMPLIANT
};
} // namespace ns1

namespace ns2 {
class C1 {};
} // namespace ns2

namespace ns3 {
void C1(); // COMPLIANT - not in scope of ns2::C1
}