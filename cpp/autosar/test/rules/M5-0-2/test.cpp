extern int f2();

void f1() {
  int l1, l2, l3;

  // Gratuitous use of parentheses in assignments
  l1 = l2 + l3;       // COMPLIANT
  l1 = (l2 + l3);     // NON_COMPLIANT
  l1 = (l2 = l3 + 1); // COMPLIANT

  // Gratuitous use of parentheses in unary operators
  l1 = l2 * -1;   // COMPLIANT
  l1 = l2 * (-1); // NON_COMPLIANT

  // Gratuitous use of parentheses in binary and ternary operators
  l1 = 1 + l2 + l3;         // COMPLIANT
  l1 = 1 + (l2 + l3);       // NON_COMPLIANT
  l1 = (2 * l2) + (3 * l3); // COMPLIANT
  l1 = (2 * l2) + l3 + 1;   // COMPLIANT

  // Parentheses can be used in nested, equivalent, operators to order the
  // operations when different types are involved
  short l4, l5;
  l1 = (l4 + l5) + l2; // COMPLIANT
  l1 = l4 + (l5 + l2); // COMPLIANT

  l1 = f2() - (l2 - l3); // NON_COMPLIANT

  int (*l6)(int, int);
  l1 = (*l6)(l2, l3); // NON_COMPLIANT[FALSE_NEGATIVE]
  int **l7;
  l1 = (*l7)[l2];           // NON_COMPLIANT[FALSE_NEGATIVE]
  char l8 = (char)(l1 + 1); // NON_COMPLIANT[FALSE_NEGATIVE]
}