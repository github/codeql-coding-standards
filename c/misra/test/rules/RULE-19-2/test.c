void f1() {
  union { // NON_COMPLIANT
    int i;
    int j;
  } l = {0};
  l.j = l.i;
}
