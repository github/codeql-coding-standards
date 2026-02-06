static void f(); // NON_COMPLIANT - prefer to use an anonymous namespace

namespace {
void f1();        // COMPLIANT
extern void f2(); // NON_COMPLIANT

int i;         // COMPLIANT
extern int i1; // NON_COMPLIANT
static int i2; // NON_COMPLIANT  - prefer to not use static as it is redundant
} // namespace

namespace named {
static const int i[] = {1}; // COMPLIANT - exception
}