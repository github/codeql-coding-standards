// It is valid to use @ in comments COMPLIANT

// Invalid character α NON_COMPLIANT
double α = 2.;                   // NON_COMPLIANT; U+03b1
void *to_𐆅_and_beyond = nullptr; // NON_COMPLIANT; U+10185
int l1_\u00A8;                   // COMPLIANT[FALSE_POSITIVE]
const char *euro1 = "α";         // NON_COMPLIANT
const wchar_t *euro2 = L"α";     // COMPLIANT
const char *euro3 = u8"α";       // COMPLIANT

int valid;
/*
Invalid character ↦ NON_COMPLIANT
*/