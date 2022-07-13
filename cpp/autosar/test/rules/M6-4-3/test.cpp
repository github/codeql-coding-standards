void f(int y);

void test_caseclausenotfirst_invalid(int expression) {
  int i = 5;
  int j;
  switch (expression) {
  start:
    expression = 4; // NON_COMPLIANT - first statement must be case clause
  case 1:
    if (i > 4) {
      j = 3;
    }
    i = 3;
    break;
  case 2:
    if (i % 2 == 0) {
      j = 1;
    }
    break;
  case 3:
    if (i % 2 == 1) {
      j = 8;
    }
    break;
  default:
    j = 5;
    break;
  }
}
void test_switch_caseclausefirst_valid(int expression) {
  int i = 5;
  int j;
  switch (expression) {
  case 2:
    if (i % 2 == 0) {
      j = 1;
    }
    break;
  case 3:
    if (i % 2 == 1) {
      j = 8;
    }
    break;
  default:
    j = 5;
    break;
  }
}

void test_notwellformedswitch_expr(int expression) {
  switch (expression) {
  case 1:
    int y = expression + 1; // NON_COMPLIANT - `DeclStmt` whose parent
    // statementis the switch body
    f(y);
    break;
  }
}
void test_notwellformedswitch_jmp(int expression) {
  int y = 2;
  switch (expression) {
  case 10:
    f(y);
    goto end; // NON_COMPLIANT - `JumpStmt` whose parent statement is the
    // switch
    // body

  case 2:
    break;
  }
end:
  expression = 3;
}

void test_notwellformedswitch_labelStmt(int expression) {
  switch (expression) {
  case 1:
  start:
    expression = 4; // NON_COMPLIANT - `LabelStmt` whose parent statement is the
                    // switch body
    break;
  }
}

void test_emptyfallthrough(int expression) {
  switch (expression) {
  case 1: // COMPLIANT
  default:
    expression = 0;
    break;
  }
}
