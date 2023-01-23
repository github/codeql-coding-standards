extern int a[1]; // COMPLIANT
extern int a1[]; // NON_COMPLIANT
extern int a2[] = {
    1}; // COMPLIANT - this rule applies to non-defining declarations only
static int a3[]; // COMPLIANT - not external linkage
int a4[];        // COMPLIANT - is a definition