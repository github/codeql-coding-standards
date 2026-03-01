class A {
  void b(int x) {} // NON_COMPLIANT

  // This is specially excluded from A0-1-4, covered by a different rule,
  // even though it's non compliant in the shared query.
  virtual void d(int x, int y) {} // COMPLIANT
};