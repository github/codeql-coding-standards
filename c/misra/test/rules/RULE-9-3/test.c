void test() {
  int l01[4] = {1, 2, 3, 4};                        // COMPLIANT
  int l02[4][2] = {{1, 2}, {3, 4}, {3, 4}, {3, 4}}; // COMPLIANT
  int l03[4][2] = {1, 2, 3, 4, 3, 4, 3, 4};         // COMPLIANT
  int l04[4][2] = {0};                              // COMPLIANT
  int l06[4][2] = {{0}, {0}, {0}, {0}};             // COMPLIANT
  int l08[4] = {1, 2};                              // NON_COMPLIANT
  int l09[2][2] = {{1, 2}};                         // NON_COMPLIANT
  int l10[2][2] = {{1, 2}, [1] = {0}};              // COMPLIANT
  int l11[2][2] = {{1, 2}, [1] = 0};                // COMPLIANT
  int l12[2][2] = {{1, 2}, [1][0] = 0, [1][1] = 0}; // COMPLIANT
  int l13[2][2] = {{0}, [1][0] = 0}; // NON_COMPLIANT - not all elements
                                     // initialized with designated initializer
  int l14[2][2] = {
      {0}, [1][0] = 0, 0}; // NON_COMPLIANT - not all elements
                           // initialized with designated initializer

  int l15[2] = {[1] = 0};         // COMPLIANT - sparse matrix initialized with
                                  // designated initializer
  int l16[2][2] = {[0] = {0, 1}}; // NON_COMPLIANT - sub-elements not
                                  // initialized with designated initializer

  int l17[4][4] = {
      [0][0] = 0, [0][1] = 0, [0][2] = 0, [0][3] = 0, [2][0] = 0,
      [2][1] = 0, [2][2] = 0, [2][3] = 0}; // COMPLIANT - sparse matrix
                                           // initialized with designated
                                           // initializer

  int l18[4][4] = {
      [0][0] = 0, [0][1] = 0, [0][2] = 0, [0][3] = 0, [2][0] = 0,
      [2][1] = 0, [2][2] = 0, [2][3] = 0, 2}; // NON_COMPLIANT - not all
                                              // elements initialized with
                                              // designated initializer

  char str1[4] = "abc"; // COMPLIANT
  char str2[5] = "abc"; // COMPLIANT - array initialized by string literal
}