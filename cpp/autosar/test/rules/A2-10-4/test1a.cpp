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

// Variable templates can cause false positives
template <int x> static int number_one = 0; // COMPLIANT

template <> static int number_one<1> = 1; // COMPLIANT
template <> static int number_one<2> = 2; // COMPLIANT
} // namespace ns3