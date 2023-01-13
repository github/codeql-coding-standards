// NOTICE: THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C++ TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.
#include <stdbool.h>

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

  int dead1 = 0, dead2 = 0; // NON_COMPLIANT
  dead1 = 1;                // NON_COMPLIANT - useless assignment
  dead2 = 1;                // NON_COMPLIANT - useless assignment

  if (false) {  // NON_COMPLIANT
    dead2 = 10; // Only used in dead or unreachable code
  }

  if (true) { // COMPLIANT
    may_have_side_effects();
  }

  if (may_have_side_effects()) { // COMPLIANT
    may_have_side_effects();
  }

  if (true) { // NON_COMPLIANT
  }

  {} // NON_COMPLIANT
  {  // NON_COMPLIANT
    1 + 2;
  }

  { // COMPLIANT
    may_have_side_effects();
  }

  do { // COMPLIANT
    may_have_side_effects();
  } while (may_have_side_effects());

  do { // COMPLIANT
    may_have_side_effects();
  } while (may_have_side_effects());

  do { // NON_COMPLIANT
  } while (no_side_effects_nondeterministic());

  while (may_have_side_effects()) { // COMPLIANT
    may_have_side_effects();
  }

  while (may_have_side_effects()) { // COMPLIANT
    may_have_side_effects();
  }

  while (no_side_effects_nondeterministic()) { // NON_COMPLIANT
  }

  may_have_side_effects(); // COMPLIANT
  1 + 2;                   // NON_COMPLIANT

  no_side_effects(x); // NON_COMPLIANT

  return live5 + live6; // COMPLIANT
}