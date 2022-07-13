extern int g1;
extern int f1(int);

void test() {
  int l1;

  if (l1 = 1) // NON_COMPLIANT
  {
  }

  if ((l1 = g1)) // COMPLIANT - exception when the assignment consists of a
                 // single primary expression.
  {
  }

  if ((l1 = g1) != 0) // COMPLIANT - assignment is itself an operand to a
                      // comparison or relational expression.
  {
  }

  do {
  } while (l1 = 1); // NON_COMPLIANT

  for (int i = 0; i = 1; i++) // NON_COMPLIANT
  {
  }

  int l2 = (l1 = 1) ? 1 : 2;  // NON_COMPLIANT
  int l3 = l1 ? l1 = 1 : 2;   // COMPLIANT
  int l4 = l1 ? 1 : (l1 = 2); // COMPLIANT

  _Bool l5 = (l1 = 1) && l1 != 2; // NON_COMPLIANT
  _Bool l6 = l1 != 2 && (l1 = 1); // NON_COMPLIANT
  _Bool l7 = (l1 = 1) || l1 != 2; // NON_COMPLIANT
  _Bool l8 = l1 != 2 || (l1 = 1); // NON_COMPLIANT

  if (((l1 = g1) != 0) && l5) // COMPLIANT - the assignment is intended
  {
  }

  if (l1 > 2, l1 = 3) // NON_COMPLIANT
  {
  }

  while (l1 = 2, l2 == l3) // COMPLIANT
  {
  }

  if (f1(l1 = l2)) // COMPLIANT
  {
  }

  int l9[2] = {0};
  if (l9[l1 = 1]) // COMPLIANT
  {
  }
}