#include <cstdlib>

int i = 0;

/**
 * Test the initializer of a switch statement.
 */
void testInitializer(int expr) {
  switch (expr) { // COMPLIANT: No initializer
  case 1:
    i++;
    break;
  default:
    i--;
    break;
  }

  switch (int j = 0;
          expr) { // COMPLIANT: Only declaration statement can be an initializer
  case 1:
    j++;
    break;
  default:
    j--;
    break;
  }

  switch (
      i = 1;
      expr) { // NON_COMPLIANT: Only declaration statement can be an initializer
  case 1:
    i++;
    break;
  default:
    i--;
    break;
  }
}

void testNestedCaseLabels(int expr) {
  switch (expr) { // COMPLIANT: Consecutive case labels are allowed
  case 1:
  case 2:
    i++;
    break;
  default:
    i--;
    break;
  }

  switch (expr) { // NON_COMPLIANT: Statements with case labels should all be at
                  // the same level
  case 1: {
  case 2:
    i++;
    break;
  }
  default:
    break;
  }

  switch (expr) { // NON_COMPLIANT: Statements with case labels should all be at
                  // the same level
  case 1:
    i++;
    break;
  case 2: {
  default:
    break;
  }
  }
}

void testOtherLabelsInBranch(int expr) {
  switch (expr) { // NON_COMPLIANT: Non-case labels appearing in a switch branch
  case 1: {
    i++;
    goto someLabel;
  someLabel:
    i++;
    break;
  }
  default:
    break;
  }
}

void testLeadingNonCaseStatement(int expr) {
  switch (expr) { // NON_COMPLIANT: Non-case statement is the first statement in
                  // the switch body
    int x = 1;
  case 1:
    i++;
    break;
  default:
    break;
  }
}

[[noreturn]] void f() { exit(0); }
void g() {}

void testSwitchBranchTerminator(int expr) {
  switch (expr) { // COMPLIANT: Break is allowed as a branch terminator
  case 1:
    i++;
    break;
  default:
    break;
  }

  for (int j = 0; j++; j < 10) {
    switch (expr) { // COMPLIANT: Continue is allowed as a branch terminator
    case 1:
      i++;
      continue;
    default:
      continue;
    }
  }

  switch (expr) { // COMPLIANT: Goto is allowed as a branch terminator
  case 1:
    i++;
    goto error;
  default:
    goto error;
  }

  switch (expr) { // COMPLIANT: Throw is allowed as a branch terminator
  case 1:
    i++;
    throw;
  default:
    throw;
  }

  switch (expr) { // COMPLIANT: Call to a `[[noreturn]]` function is allowed as
                  // a branch terminator
  case 1:
    i++;
    f();
  default:
    f();
  }

  switch (expr) { // NON_COMPLIANT: Branch ends with a call to a function that
                  // is not `[[noreturn]]`
  case 1:
    i++;
    g();
  default:
    g();
  }

  switch (expr) { // COMPLIANT: Return is allowed as a branch terminator
  case 1:
    i++;
    return;
  default:
    return;
  }

  switch (expr) { // COMPLIANT: Empty statement with `[[fallthrough]]` is
                  // allowed as a branch terminator
  case 1:
    i++;
    [[fallthrough]];
  default:
    i++;
    break;
  }

error:
  return;
}

void testSwitchBranchCount(int expr) {
  switch (expr) { // COMPLIANT: Branch count is 2
  case 1:
    i++;
    break;
  default:
    i++;
    break;
  }

  switch (expr) { // NON_COMPLIANT: Branch count is 1
  default:
    i++;
    break;
  }

  switch (expr) { // NON_COMPLIANT: Branch count is 1
  case 1:
  case 2:
  default:
    i++;
    break;
  }
}

enum E { V1, V2, V3 };

void testDefaultLabelPresence(int expr) {
  switch (expr) { // COMPLIANT: There is a default branch
  case 1:
    i++;
    break;
  default:
    i++;
    break;
  }

  switch (expr) { // NON_COMPLIANT: Default branch is missing
  case 1:
    i++;
    break;
  }

  E e;

  switch (e) { // COMPLIANT: There is a default branch
  case V1:
    i++;
    break;
  default:
    break;
  }

  switch (e) { // NON_COMPLIANT: Default branch is missing on a non-exhaustive
               // enum switch
  case V1:
    i++;
    break;
  case V2:
    i++;
    break;
  }

  switch (e) { // COMPLIANT: Default branch can be omitted on an exhaustive enum
               // switch
  case V1:
    i++;
    break;
  case V2:
    i++;
    break;
  case V3:
    i++;
    break;
  }
}