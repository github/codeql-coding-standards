// It is valid to use @ in comments COMPLIANT

// Invalid character α NON_COMPLIANT
double α = 2.;                   // NON_COMPLIANT; U+03b1
void *to_𐆅_and_beyond = nullptr; // NON_COMPLIANT; U+10185
int l1_\u00A8;                   // COMPLIANT[FALSE_POSITIVE]
const char *euro = "α";          // NON_COMPLIANT

int valid;
/*
Invalid character ↦ NON_COMPLIANT
*/