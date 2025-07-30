// Test cases for RULE-9-4-2: The structure of a switch statement shall be
// appropriate This rule combines RULE-16-1 through RULE-16-7

void test_rule_16_1_well_formed(int expr) {
  int i = 0;

  // COMPLIANT - well-formed switch with proper statements
  switch (expr) {
  case 1:
    i++; // expression statement
    break;
  case 2: { // compound statement
    i++;
  } break;
  case 3:
    if (i > 0) { // selection statement
      i++;
    }
    break;
  case 4:
    while (i < 10) { // iteration statement
      i++;
    }
    break;
  default:
    break;
  }

  // NON_COMPLIANT - switch with inappropriate statement (declaration)
  switch (expr) {
  case 1:
    int j = 5; // declaration statement - not allowed
    break;
  default:
    break;
  }
}

void test_rule_16_2_nested_labels(int expr) {
  // COMPLIANT - labels directly within switch body
  switch (expr) {
  case 1:
    break;
  case 2:
    break;
  default:
    break;
  }

  // NON_COMPLIANT - nested switch labels (this would be a compiler error in
  // practice) switch (expr) { case 1:
  //   {
  //     case 2:  // nested label - not allowed
  //       break;
  //   }
  //   break;
  // default:
  //   break;
  // }
}

void test_rule_16_3_termination(int expr) {
  int i = 0;

  // COMPLIANT - all cases properly terminated
  switch (expr) {
  case 1:
    i++;
    break;
  case 2:
  case 3: // empty cases are fine
    i++;
    break;
  case 4:
    throw "error"; // throw is also valid termination
  default:
    break;
  }

  // NON_COMPLIANT - case 1 falls through without break
  switch (expr) {
  case 1: // NON_COMPLIANT - missing break
    i++;
  case 2: // COMPLIANT - properly terminated
    i++;
    break;
  default:
    break;
  }

  // NON_COMPLIANT - default case falls through
  switch (expr) {
  case 1:
    i++;
    break;
  default: // NON_COMPLIANT - missing break
    i++;
  }
}

void test_rule_16_4_default_label(int expr) {
  int i = 0;

  // COMPLIANT - has default label
  switch (expr) {
  case 1:
    i++;
    break;
  case 2:
    i++;
    break;
  default:
    break;
  }

  // NON_COMPLIANT - missing default label
  switch (expr) {
  case 1:
    i++;
    break;
  case 2:
    i++;
    break;
  }
}

void test_rule_16_5_default_position(int expr) {
  int i = 0;

  // COMPLIANT - default is first
  switch (expr) {
  default:
    i++;
    break;
  case 1:
    i++;
    break;
  case 2:
    i++;
    break;
  }

  // COMPLIANT - default is last
  switch (expr) {
  case 1:
    i++;
    break;
  case 2:
    i++;
    break;
  default:
    i++;
    break;
  }

  // NON_COMPLIANT - default is in the middle
  switch (expr) {
  case 1:
    i++;
    break;
  default: // NON_COMPLIANT - not first or last
    i++;
    break;
  case 2:
    i++;
    break;
  }
}

void test_rule_16_6_two_clauses(int expr) {
  int i = 0;

  // COMPLIANT - has multiple clauses
  switch (expr) {
  case 1:
    i++;
    break;
  case 2:
    i++;
    break;
  default:
    break;
  }

  // NON_COMPLIANT - only has default (single clause)
  switch (expr) {
  default:
    i++;
    break;
  }

  // NON_COMPLIANT - only has one case plus default (still only one effective
  // clause)
  switch (expr) {
  case 1:
  default:
    i++;
    break;
  }
}

void test_rule_16_7_boolean_expression() {
  int i = 0;
  bool flag = true;

  // COMPLIANT - non-boolean expression
  switch (i) {
  case 0:
    break;
  case 1:
    break;
  default:
    break;
  }

  // NON_COMPLIANT - boolean expression
  switch (flag) {
  case true:
    break;
  case false:
    break;
  default:
    break;
  }

  // NON_COMPLIANT - boolean comparison expression
  switch (i == 0) {
  case true:
    break;
  case false:
    break;
  default:
    break;
  }
}

int f() { return 1; }

void test_complex_violations(int expr) {
  int i = 0;
  bool flag = true;

  // NON_COMPLIANT - multiple violations:
  // - Boolean expression (16-7)
  // - Missing default (16-4)
  // - Single clause (16-6)
  switch (flag) {
  case true:
    i++;
  }

  // NON_COMPLIANT - multiple violations:
  // - Fall-through case (16-3)
  // - Default not first/last (16-5)
  switch (expr) {
  case 1: // NON_COMPLIANT - falls through
    i++;
  default: // NON_COMPLIANT - not first/last
    i++;
    break;
  case 2:
    i++;
    break;
  }

  switch (expr) {
    int i = 0;
  case 1:
    i++;
  }
  
  switch (int x = f(); x) {
  case 1:
    i++;
  }

  switch (expr = f(); expr) {
  case 1:
    i++;
  }

  switch (expr) {
  case 1:
    {
      case 2:
      i++;
    }
  }

  switch (expr) {
  case 1: {
    i++;
    goto someLabel;
  someLabel:
    i++;
  }
  }

  switch (expr) {
    int x = 1;
  case 1:
    i++;
  }
}