extern g; // NON_COMPLIANT

extern int g1; // COMPLIANT

f(void) { // NON_COMPLIANT
  return 1;
}

int f1(void) { // COMPLIANT
  return 1;
}

short g2;                 // COMPLIANT
long g3;                  // COMPLIANT
signed g4() { return 1; } // COMPLIANT

typedef *newtype3; // NON_COMPLIANT[FALSE_NEGATIVE]

int f2(const x) { // NON_COMPLIANT[FALSE_NEGATIVE]
  return 1;
}

struct str {
  const y; // NON_COMPLIANT[FALSE_NEGATIVE]
} s;
