union U1 {
  int x;  // COMPLIANT
  char y; // COMPLIANT
};

union U2 {
  int x : 2; // NON-COMPLIANT
  char y;    // COMPLIANT
};

union U3 {
  struct str {
    int x : 4; // COMPLIANT
    int y : 2; // COMPLIANT
  };
};

union U4 {
  char x;
  int : 0; // NON-COMPLIANT
};