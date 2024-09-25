int may_have_side_effects();
int no_side_effects(int x) { return 1 + 2; }
int no_side_effects_nondeterministic();

int test_dead_code(int x) {
  int live1 = may_have_side_effects(),
      live2 = may_have_side_effects(); // COMPLIANT
  int live3 = 0,
      live4 = may_have_side_effects(); // COMPLIANT
  int live5 = 0, live6 = 0;            // COMPLIANT
  live5 = 1;                           // COMPLIANT
  live6 = 2;                           // COMPLIANT

  int dead1 = 0, dead2 = 0; // COMPLIANT - init not considered by this rule
  dead1 = 1;                // NON_COMPLIANT - useless assignment
  dead2 = 1;                // NON_COMPLIANT - useless assignment

  may_have_side_effects(); // COMPLIANT
  1 + 2;                   // NON_COMPLIANT

  no_side_effects(x); // NON_COMPLIANT

  (int)may_have_side_effects(); // NON_COMPLIANT
  (int)no_side_effects(x);      // NON_COMPLIANT
  (void)no_side_effects(x);     // COMPLIANT
  (may_have_side_effects());    // COMPLIANT
  (no_side_effects(x));         // NON_COMPLIANT

  return live5 + live6; // COMPLIANT
}