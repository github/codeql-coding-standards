int32_t i1; int32_t j1; // Compliant
int32_t i2, *j2;        // Non-compliant
int32_t *i3,
        &j3 = i2;       // Non-compliant