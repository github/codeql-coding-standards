extern int i;
i = 0; // COMPLIANT

extern int i1 = 0; // NON_COMPLIANT

int i2 = 0; // NON_COMPLIANT

extern int i3; // NON_COMPLIANT - not detected as `short i3` exists

extern int i4; // COMPLIANT