int f1(int i) {
  if (i < 0) {
    throw "Error: out-of-range";
  }

  static const int c[] = {f1(0), f1(1), f1(2)}; // NON_COMPLIANT - recursive

  // Stored in cache
  if (i > 0 && i <= 2) {
    return c[i];
  }

  return i == 0 ? 1 : f1(i - 1) * i;
}

int f2(int i) { return i <= 0 ? 1 : f2(i - 1) * i; }

int v1 = f2(10); // COMPLIANT - initialized with recursion, but not a recursive
                 // declaration

extern int v3;
int v2 = v3; // NON_COMPLIANT - initializer for `v2` is recursive via `v3`
int v3 = v2; // NON_COMPLIANT - initializer for `v3` is recursive via `v2`