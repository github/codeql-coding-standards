const char *g = "??=";  // NON_COMPLIANT
const char *g1 = "??/"; // NON_COMPLIANT
const char *g2 = "??'"; // NON_COMPLIANT
const char *g3 = "??("; // NON_COMPLIANT
const char *g4 = "??)"; // NON_COMPLIANT
const char *g5 = "??!"; // NON_COMPLIANT
const char *g6 = "??<"; // NON_COMPLIANT
const char *g7 = "??>"; // NON_COMPLIANT
const char *g8 = "??-"; // NON_COMPLIANT

const char *g9 = "\?\?="; // COMPLIANT
const char *g10 = "?=";   // COMPLIANT

// comment trigraph-like ??= // NON_COMPLIANT

// clang-format off
#define TRIGRAPH_LIKE ??= // NON_COMPLIANT - format off otherwise it separates the characters