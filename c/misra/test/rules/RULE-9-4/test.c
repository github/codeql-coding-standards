struct s1 {
  int a;
  int b;
};

void test_arrays(void) {
  int a1[2] = {1, 2};             // COMPLIANT
  int a2[2] = {[0] = 1, [1] = 2}; // COMPLIANT
  int a3[2] = {
      0, [0] = 1, [1] = 2}; // NON_COMPLIANT - repeated initialiation of [0]
  int a4[2][2] = {[0][0] = 1, [0][1] = 2, [1][0] = 3, [1][1] = 4}; // COMPLIANT
  int a5[2][2] = {[0][0] = 1,
                  [0][1] = 2,
                  [1][0] = 3,
                  [1][1] = 4,
                  [0][0] = 1}; // NON_COMPLIANT
                               // - repeated
                               // initialiation
                               // of [0][0]
  int a6[2][2][2] = {
      [0][0][0] = 1, [0][0][1] = 2, [0][1][0] = 3, [0][1][1] = 4,
      [1][0][0] = 5, [1][0][1] = 6, [1][1][0] = 7, [1][1][1] = 8}; // COMPLIANT

  int a7[2][2][2] = {[0][0][0] = 1, [0][0][1] = 2, [0][1][0] = 3, [0][1][1] = 4,
                     [1][0][0] = 5, [1][0][1] = 6, [1][1][0] = 7, [1][1][1] = 8,
                     [1][1][0] = 1}; // NON_COMPLIANT
                                     // - repeated
                                     // initialiation
                                     // of [0][0][0]
}

void test_structs(void) {
  struct s1 s1 = {0};              // COMPLIANT
  struct s1 s2 = {0, 1};           // COMPLIANT
  struct s1 s3 = {.a = 0, .b = 1}; // COMPLIANT
  struct s1 s4 = {.a = 0,
                  .a = 1}; // NON_COMPLIANT - repeated initialiation of .a
}