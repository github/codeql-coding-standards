// Note: A subset of these cases are also tested in c/misra/test/rules/RULE-1-5
// via a MissingStaticSpecifierObjectRedeclarationC.qlref and .expected file in
// that directory. Changes to these tests may require updating the test code or
// expectations in that directory as well.

static int g = 0;
extern int g; // NON_COMPLIANT

static int g1;
static int g1 = 0; // COMPLIANT

int g2;
int g2 = 0; // COMPLIANT
