int g1 = sizeof(int); // COMPLIANT

int g2;

int g3 = sizeof(g2++); // NON_COMPLIANT

int f1(int &p1) { return p1++; }

int g4 = sizeof(f1(g2)); // NON_COMPLIANT