void f1(int ar[3]);
void f2(int a, int ar[3]);
void f3(int *ar);
void f4(int a, int *ar);

void t1() {
  int *ar;

  int ar2[3] = {1, 2};
  int *ar2p = ar2;

  int ar3[3] = {1, 2, 3};
  int *ar3p = ar3;

  int ar4[4] = {1, 2, 3};
  int *ar4p = ar4;

  f1(0);    // NON_COMPLAINT
  f1(ar);   // NON_COMPLAINT
  f1(ar2);  // NON_COMPLIANT
  f1(ar2p); // NON_COMPLIANT
  f1(ar3);  // COMPLIANT
  f1(ar3p); // COMPLIANT
  f1(ar4);  // COMPLIANT

  f2(0, 0);    // NON_COMPLAINT
  f2(0, ar);   // NON_COMPLAINT
  f2(0, ar2);  // NON_COMPLIANT
  f2(0, ar2p); // NON_COMPLIANT
  f2(0, ar3);  // COMPLIANT
  f2(0, ar3p); // COMPLIANT
  f2(0, ar4);  // COMPLIANT

  f3(0);    // COMPLAINT
  f3(ar);   // COMPLAINT
  f3(ar2);  // COMPLIANT
  f3(ar2p); // COMPLIANT
  f3(ar3);  // COMPLIANT
  f3(ar3p); // COMPLIANT
  f3(ar4);  // COMPLIANT

  f4(0, 0);    // COMPLAINT
  f4(0, ar);   // COMPLAINT
  f4(0, ar2);  // COMPLIANT
  f4(0, ar2p); // COMPLIANT
  f4(0, ar3);  // COMPLIANT
  f4(0, ar3p); // COMPLIANT
  f4(0, ar4);  // COMPLIANT
}