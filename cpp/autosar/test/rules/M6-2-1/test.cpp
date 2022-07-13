extern int f1();
void f2() {
  int l1, l2, l3;

  l1 = 1, l2 = 2,
  l3 = 3;       // COMPLIANT, there cannot be a confusion between '=' and '=='
  l1 = l2 = l3; // NON_COMPLIANT

  if ((l1 = l2) == l3) { // NON_COMPLIANT
  }

  l1 = l2 == l3; // COMPLIANT

  if (int i =
          f1()) { // COMPLIANT, there cannot be a confusion between '=' and '=='
  }

  for (int i = 0; i < 10; ++i) { // COMPLIANT
  }
}