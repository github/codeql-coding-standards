// The following are compliant
int16_t a1[5]    = { 1, 2, 3, 0, 0 }; // Non-zero initialization
int16_t a2[5]    = { 0 };             // Zero initialization
int16_t a3[2][2] = { };               // Zero initialization
// The following are non-compliant
int16_t a4[5]    = { 1, 2, 3 };       // Partial initialization
int16_t a5[2][2] = { { }, { 1, 2 } }; // Zero initialization
                                      // at sub-level