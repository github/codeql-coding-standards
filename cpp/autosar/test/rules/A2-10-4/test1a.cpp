namespace ns1 {
static int v1 = 0;
int v2 = 0;
} // namespace ns1

namespace ns2 {
static int v1 = 1; // COMPLIANT
}

static int v1 = 2; // COMPLIANT

namespace ns3 {
static void f1() {}

void f2() {}
} // namespace ns3