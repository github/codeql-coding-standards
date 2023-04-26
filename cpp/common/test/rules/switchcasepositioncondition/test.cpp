void f1(int p1);

void f2(int p1) {

  switch (p1) {
  start:; // NON_COMPLIANT
  case 1:
    if (p1) {
      ;
    };
    break;
  case 2:
    if (p1) {
      ;
    }
    break;
  case 3:
    if (p1) {
      ;
    }
    break;
  default:;
    break;
  }
}
void f3(int p1) {

  switch (p1) { // COMPLIANT
  case 2:
    if (p1) {
      ;
    }
    break;
  case 3:
    if (p1) {
      ;
    }
    break;
  default:;
    break;
  }
}
