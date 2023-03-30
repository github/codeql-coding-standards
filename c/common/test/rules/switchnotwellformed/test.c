
void f1();
void f2(int p1) {
  switch (p1) {
  case 1:
    f1();
    int y = p1; // NON_COMPLIANT - `DeclStmt` whose parent
    // statement is the switch body
    f1();
    break;
  }
}
void f3(int p1) {
  switch (p1) {
  case 10:
    f1();
    goto L1; // NON_COMPLIANT - `JumpStmt` whose parent statement is the//
             // switch// body
  case 2:
    break;
  }
L1:;
}

void f4(int p1) {
  switch (p1) {
  case 1:
  L1:; // NON_COMPLIANT - `LabelStmt` whose parent statement is the
       // switch body
    break;
  }
}

void f5(int p1) {
  switch (p1) {
  case 1: // COMPLIANT
  default:
    p1 = 0;
    break;
  }
}
