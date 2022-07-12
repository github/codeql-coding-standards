void f1() {
  int l1, l2, l3;

  l3 = l1++ + l2--; // NON_COMPLIANT
  l3 = ++l1 * --l2; // NON_COMPLIANT
  ++l1;             // COMPLIANT
  --l2;             // COMPLIANT
  l3 = l1 * l2;
}